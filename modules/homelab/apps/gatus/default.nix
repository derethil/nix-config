{self, ...}: let
  appImage = "docker.io/twinproduction/gatus";
  appVersion = "v5.38.0";
  appDigest = "sha256:085ed63da963728965d00a3c78aa6167e3bf135218485b893201758e079e8415";

  postgresImage = "docker.io/library/postgres";
  postgresVersion = "19.0-alpine";
  postgresDigest = "sha256:cac45fb483caee3668946088a1c0532db89d5285c28dbfeac889b4068296e06f";

  subdomain = "health";
  port = "20030";
  internalPort = "8080";

  # TODO:
  # - Configure restic backups to send durations to Gatus along with status and error messages.
  # - Replace internet endpoint with the proper 'connectivity' that turns off checks when it goes red.

  inherit (self.lib.podman) svc user;
in {
  flake.modules = self.factory.container-app {
    name = "gatus";

    nixos = {config, ...}: {
      imports = [
        self.modules.nixos.gatus-options
        self.modules.nixos.gatus-config-file
        self.modules.nixos.gatus-endpoints
        self.modules.nixos.ingress
        self.modules.nixos.quadlet
        self.modules.nixos.restic
        self.modules.nixos.secrets
      ];

      internal.homelab = {
        backups.gatus = {
          databases.postgres = [
            {
              container = "gatus-db";
              database = "gatus";
              user = "gatus";
            }
          ];

          restore.services = {
            afterRestore = map svc ["gatus-web"];
            afterSync = map svc ["gatus-pod" "gatus-db"];
            stop = map svc ["gatus-web" "gatus-db" "gatus-pod"];
          };
        };

        gatus = {
          inherit internalPort;
          pushUrl = config.internal.homelab.ingress.gatus.url;
        };

        ingress.gatus = {
          inherit port subdomain;
        };
      };

      sops = {
        secrets = {
          "serve/gatus/ntfy_topic".mode = "0444";
          "serve/gatus/postgres_password" = {};
          "serve/gatus/token" = {};
        };

        templates."gatus-env" = {
          mode = "0400";
          content = ''
            POSTGRES_DB=gatus
            POSTGRES_USER=gatus
            POSTGRES_PASSWORD=${config.sops.placeholder."serve/gatus/postgres_password"}
            GATUS_TOKEN=${config.sops.placeholder."serve/gatus/token"}
            NTFY_TOPIC=${config.sops.placeholder."serve/gatus/ntfy_topic"}
          '';
          owner = user;
        };
      };

      assertions = [
        {
          assertion = config.internal.homelab.gatus.configFile != null;
          message = "internal.homelab.gatus.configFile must be set to a valid path.";
        }
      ];
    };

    quadlet = {
      config,
      osConfig,
      ...
    }: let
      inherit (config.virtualisation.quadlet) pods;

      envFile = osConfig.sops.templates."gatus-env".path;
    in {
      containers = {
        gatus-db = self.lib.quadlet.mkQuadletPostgresPod config "gatus" {
          containerConfig = {
            environmentFiles = [envFile];
            image = "${postgresImage}:${postgresVersion}@${postgresDigest}";
          };
        };

        gatus-web = {
          containerConfig = {
            dropCapabilities = ["ALL"];
            environmentFiles = [envFile];
            image = "${appImage}:${appVersion}@${appDigest}";
            noNewPrivileges = true;
            pod = pods.gatus.ref;
            pull = "newer";

            volumes = [
              "${osConfig.internal.homelab.gatus.configFile}:/config/config.yaml:ro"
            ];
          };

          serviceConfig.Restart = "always";

          unitConfig = {
            After = map svc ["gatus-db"];
            Description = "Gatus Health Dashboard";
            Wants = map svc ["gatus-db"];
          };
        };
      };

      pods.gatus = self.lib.quadlet.mkQuadletPod port internalPort;
      volumes.gatus-db = {};
    };
  };
}
