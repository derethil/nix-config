{
  self,
  lib,
  ...
}: let
  inherit (lib) getExe';

  appImage = "ghcr.io/bookorbit/bookorbit";
  appVersion = "3.8.0";
  appDigest = "sha256:d318f7732f6f6330312e2c5f854f7899f858b54cc4b18a13cde1f43b5bea0515";

  postgresImage = "docker.io/pgvector/pgvector";
  postgresVersion = "pg18";
  postgresDigest = "sha256:c29f30688a9ad961691bdf0ec1650717cc132a5814619d80f80463d6e4c42e47";

  subdomain = "books";
  port = "20040";
  internalPort = "3000";

  puid = "1000";
  pgid = "1000";

  inherit (self.lib.podman) svc user volume;
in {
  flake.modules = self.factory.container-app {
    name = "bookorbit";

    nixos = {config, ...}: {
      imports = [
        self.modules.nixos.gatus-options
        self.modules.nixos.ingress
        self.modules.nixos.quadlet
        self.modules.nixos.restic
        self.modules.nixos.secrets
      ];

      internal.homelab = {
        backups.bookorbit = {
          databases.postgres = [
            {
              container = "bookorbit-db";
              database = "bookorbit";
              user = "bookorbit";
            }
          ];

          files.paths = map volume ["bookorbit-books" "bookorbit-data"];

          restore.services = {
            afterRestore = map svc ["bookorbit-web"];
            afterSync = map svc ["bookorbit-pod" "bookorbit-db"];
            stop = map svc ["bookorbit-web" "bookorbit-db" "bookorbit-pod"];
          };
        };

        gatus.endpoints.bookorbit = {};

        ingress.bookorbit = {
          inherit port subdomain;
        };
      };

      sops = {
        secrets = {
          "serve/bookorbit/book_request_encryption_key" = {};
          "serve/bookorbit/jwt_secret" = {};
          "serve/bookorbit/postgres_password" = {};
          "serve/bookorbit/setup_bootstrap_token" = {};
        };

        templates."bookorbit-env" = {
          mode = "0400";
          content = ''
            POSTGRES_DB=bookorbit
            POSTGRES_USER=bookorbit
            POSTGRES_PASSWORD=${config.sops.placeholder."serve/bookorbit/postgres_password"}
            JWT_SECRET=${config.sops.placeholder."serve/bookorbit/jwt_secret"}
            SETUP_BOOTSTRAP_TOKEN=${config.sops.placeholder."serve/bookorbit/setup_bootstrap_token"}
            BOOK_REQUEST_ENCRYPTION_KEY=${config.sops.placeholder."serve/bookorbit/book_request_encryption_key"}
          '';
          owner = user;
        };
      };
    };

    quadlet = {
      config,
      pkgs,
      osConfig,
      ...
    }: let
      inherit (config.virtualisation.quadlet) pods;

      url = "https://${subdomain}.${osConfig.internal.homelab.domain}";
      envFile = osConfig.sops.templates."bookorbit-env".path;

      podman = getExe' pkgs.podman "podman";
      chown = getExe' pkgs.coreutils "chown";
    in {
      containers = {
        bookorbit-db = {
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
            image = "${postgresImage}:${postgresVersion}@${postgresDigest}";
            noNewPrivileges = true;
            pod = pods.bookorbit.ref;
            pull = "newer";
            volumes = ["bookorbit-db:/var/lib/postgresql"];
          };

          serviceConfig.Restart = "always";
          unitConfig.Description = "BookOrbit PostgreSQL Database";
        };

        bookorbit-web = {
          containerConfig = {
            addCapabilities = [
              "CHOWN"
              "DAC_OVERRIDE"
              "FOWNER"
              "SETGID"
              "SETUID"
            ];

            dropCapabilities = ["ALL"];
            environmentFiles = [envFile];

            environments = {
              APP_URL = url;
              BOOK_DOCK_PATH = "/data/downloads/book-dock";
              OIDC_ALLOW_LOCAL_ISSUERS = "true";
              PGID = pgid;
              PORT = internalPort;
              POSTGRES_HOST = "localhost";
              POSTGRES_PORT = "5432";
              PUID = puid;
            };

            image = "${appImage}:${appVersion}@${appDigest}";
            noNewPrivileges = true;
            pod = pods.bookorbit.ref;
            pull = "newer";

            volumes = [
              "bookorbit-books:/books"
              "bookorbit-data:/data"
              "sabnzbd-downloads:/data/downloads"
            ];
          };

          serviceConfig = {
            ExecStartPre = "${podman} unshare ${chown} ${puid}:${pgid} ${volume "bookorbit-books"} ${volume "bookorbit-data"}";
            Restart = "always";
          };

          unitConfig = {
            After = map svc ["bookorbit-db"];
            Description = "BookOrbit Library Manager";
            Wants = map svc ["bookorbit-db"];
          };
        };
      };

      pods.bookorbit = {
        autoStart = true;

        podConfig = {
          exitPolicy = "continue";
          publishPorts = ["127.0.0.1:${port}:${internalPort}"];
        };
      };

      volumes = {
        bookorbit-books = {};
        bookorbit-data = {};
        bookorbit-db = {};
      };
    };
  };
}
