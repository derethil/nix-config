{self, ...}: let
  appImage = "ghcr.io/pocket-id/pocket-id";
  appVersion = "v2.19.2";
  appDigest = "sha256:3ee23895d6a3adb5dd5de801a4fd31fc31b960e6dfbea9b5200e33cf477695eb";

  postgresImage = "docker.io/library/postgres";
  postgresVersion = "17-alpine";
  postgresDigest = "sha256:e5d2edd28b1f8d40a0a6c0c9cdc545b19b56a0d5d88f94bc11a97d970d4700d0";

  subdomain = "auth";
  port = "20060";
  internalPort = "1411";

  inherit (self.lib.podman) svc user volume;
in {
  flake.modules = self.factory.container-app {
    name = "pocket-id";

    nixos = {config, ...}: let
      url = config.internal.homelab.ingress.pocket-id.url;
    in {
      imports = [
        self.modules.nixos.gatus-options
        self.modules.nixos.ingress
        self.modules.nixos.oidc-options
        self.modules.nixos.quadlet
        self.modules.nixos.restic
        self.modules.nixos.secrets
      ];

      internal.homelab = {
        backups.pocket-id = {
          databases.postgres = [
            {
              container = "pocket-id-db";
              database = "pocketid";
              user = "pocketid";
            }
          ];

          files.paths = map volume ["pocket-id-data"];

          restore.services = {
            afterRestore = map svc ["pocket-id-web"];
            afterSync = map svc ["pocket-id-pod" "pocket-id-db"];
            stop = map svc ["pocket-id-web" "pocket-id-db" "pocket-id-pod"];
          };
        };

        gatus.endpoints.pocket-id.group = "infrastructure";

        ingress.pocket-id = {
          inherit port subdomain;
        };

        oidc = {
          discoveryUrl = "${url}/.well-known/openid-configuration";
          endSessionUrl = "${url}/api/oidc/end-session";
          issuerUrl = url;
          name = "Pocket ID";
          providerId = "pocket-id";
        };
      };

      sops = {
        secrets = {
          "serve/pocket_id/encryption_key" = {};
          "serve/pocket_id/maxmind_license_key" = {};
          "serve/pocket_id/postgres_password" = {};
        };

        templates."pocket-id-env" = {
          mode = "0400";
          content = ''
            MAXMIND_LICENSE_KEY=${config.sops.placeholder."serve/pocket_id/maxmind_license_key"}
            ENCRYPTION_KEY=${config.sops.placeholder."serve/pocket_id/encryption_key"}
            POSTGRES_DB=pocketid
            POSTGRES_USER=pocketid
            POSTGRES_PASSWORD=${config.sops.placeholder."serve/pocket_id/postgres_password"}
            DB_CONNECTION_STRING=postgres://pocketid:${config.sops.placeholder."serve/pocket_id/postgres_password"}@localhost:5432/pocketid
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

      url = osConfig.internal.homelab.ingress.pocket-id.url;
      envFile = osConfig.sops.templates."pocket-id-env".path;
    in {
      containers = {
        pocket-id-db = {
          containerConfig = {
            addCapabilities = [
              "CHOWN"
              "DAC_READ_SEARCH"
              "FOWNER"
              "SETGID"
              "SETUID"
            ];

            dropCapabilities = ["ALL"];
            environmentFiles = [envFile];

            environments = {
              POSTGRES_DB = "pocketid";
              POSTGRES_USER = "pocketid";
            };

            image = "${postgresImage}:${postgresVersion}@${postgresDigest}";
            noNewPrivileges = true;
            pod = pods.pocket-id.ref;
            pull = "newer";
            volumes = ["pocket-id-db:/var/lib/postgresql/data"];
          };

          serviceConfig.Restart = "always";
          unitConfig.Description = "Pocket ID PostgreSQL Database";
        };

        pocket-id-web = {
          containerConfig = {
            addCapabilities = ["CHOWN" "SETGID" "SETUID"];
            dropCapabilities = ["ALL"];
            environmentFiles = [envFile];

            environments = {
              ALLOW_INSECURE_CALLBACK_URLS = "false";
              APP_URL = url;
              TRUST_PROXY = "127.0.0.1";
            };

            image = "${appImage}:${appVersion}@${appDigest}";
            noNewPrivileges = true;
            pod = pods.pocket-id.ref;
            pull = "newer";
            volumes = ["pocket-id-data:/app/data"];
          };

          serviceConfig.Restart = "always";

          unitConfig = {
            After = map svc ["pocket-id-db"];
            Description = "Pocket ID OIDC Provider";
            Requires = map svc ["pocket-id-db"];
          };
        };
      };

      pods.pocket-id = {
        autoStart = true;

        podConfig = {
          exitPolicy = "continue";
          publishPorts = ["127.0.0.1:${port}:${internalPort}"];
        };
      };

      volumes = {
        pocket-id-data = {};
        pocket-id-db = {};
      };
    };
  };
}
