{
  self,
  lib,
  ...
}: let
  inherit (lib) getExe mkIf mkMerge mkOption removeSuffix types;
  inherit (self.lib.podman) socket svc user volume;

  appImage = "ghcr.io/amir20/dozzle";
  appVersion = "v11.4.3";
  appDigest = "sha256:244f218c876d6ed766277e71a537f34bfb2c01829e1927737e3673a8327deeb8";

  subdomain = "logs";
  port = "20110";
  internalPort = "8080";

  groupLabel = "dev.dozzle.group";
in {
  flake.modules = mkMerge [
    (self.factory.container-app {
      name = "dozzle";

      nixos = {config, ...}: {
        imports = [
          self.modules.nixos.gatus-options
          self.modules.nixos.ingress
          self.modules.nixos.oidc-options
          self.modules.nixos.quadlet
          self.modules.nixos.restic
          self.modules.nixos.secrets
        ];

        internal.homelab = {
          backups.dozzle = {
            files.paths = map volume ["dozzle-data"];

            restore.services = {
              afterRestore = map svc ["dozzle-web"];
              afterSync = map svc ["dozzle-pod"];
              stop = map svc ["dozzle-web" "dozzle-pod"];
            };
          };

          gatus.endpoints.dozzle = {};

          ingress.dozzle = {
            inherit port subdomain;
          };
        };

        sops = {
          secrets = {
            "serve/dozzle/mcp_token" = {};
            "serve/dozzle/oidc/client_id" = {};
            "serve/dozzle/oidc/client_secret" = {};
            "serve/gatus/ntfy_topic" = {};
          };

          templates."dozzle-env" = {
            mode = "0400";
            content = ''
              DOZZLE_AUTH_OIDC_CLIENT_ID=${config.sops.placeholder."serve/dozzle/oidc/client_id"}
              DOZZLE_AUTH_OIDC_CLIENT_SECRET=${config.sops.placeholder."serve/dozzle/oidc/client_secret"}
              DOZZLE_MCP_TOKEN=${config.sops.placeholder."serve/dozzle/mcp_token"}
              NTFY_TOPIC=${config.sops.placeholder."serve/gatus/ntfy_topic"}
            '';
            owner = user;
          };
        };
      };

      quadlet = {
        config,
        osConfig,
        ...
      }: let
        inherit (config.virtualisation.quadlet) pods;
        inherit (osConfig.internal.homelab) oidc;
      in {
        containers.dozzle-web = {
          containerConfig = {
            dropCapabilities = ["ALL"];
            environmentFiles = [osConfig.sops.templates."dozzle-env".path];

            environments = {
              DOZZLE_AUTH_LOGOUT_URL = oidc.endSessionUrl;
              DOZZLE_AUTH_OIDC_ISSUER = oidc.issuerUrl;
              DOZZLE_AUTH_OIDC_NAME = oidc.name;
              DOZZLE_AUTH_PROVIDER = "oidc";
              DOZZLE_ENABLE_MCP = "true";
              DOZZLE_FILTER = "label=${groupLabel}";
              DOZZLE_HOSTNAME = osConfig.networking.hostName;
              DOZZLE_IMAGE_CHECK_MODE = "off";
              DOZZLE_NO_ANALYTICS = "true";
              DOZZLE_RELEASE_CHECK_MODE = "manual";
            };

            image = "${appImage}:${appVersion}@${appDigest}";
            noNewPrivileges = true;
            pod = pods.dozzle.ref;
            pull = "newer";

            volumes = [
              "dozzle-data:/data"
              "${socket}:/var/run/docker.sock:ro"
            ];
          };

          serviceConfig.Restart = "always";

          unitConfig = {
            After = ["podman.socket"];
            Description = "Dozzle Container Log Viewer";
            Wants = ["podman.socket"];
          };
        };

        pods.dozzle = self.lib.quadlet.mkQuadletPod port internalPort;
        volumes.dozzle-data = {};
      };
    })

    {
      homeManager = {
        dozzle-mcp = {
          config,
          pkgs,
          ...
        }: let
          url = "https://${subdomain}.${config.internal.homelab.domain}/api/mcp";
        in {
          imports = [
            self.modules.generic.homelab-options
            self.modules.homeManager.mcp
          ];

          programs.mcp.servers.dozzle.command = toString (pkgs.writeShellScript "dozzle-mcp" ''
            TOKEN=$(cat ${config.sops.secrets."serve/dozzle/mcp_token".path})
            exec ${getExe pkgs.inputs.llm-agents.mcp-remote} ${url} \
              --header "Authorization: Bearer $TOKEN"
          '');

          sops.secrets."serve/dozzle/mcp_token" = {};
        };

        quadlet.options.virtualisation.quadlet.containers = mkOption {
          type = types.attrsOf (types.submodule ({config, ...}: {
            config.containerConfig.labels = mkIf (config.containerConfig.pod != null) {
              ${groupLabel} = removeSuffix ".pod" config.containerConfig.pod;
            };
          }));
        };
      };
    }
  ];
}
