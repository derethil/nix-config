{self, ...}: {
  flake.modules.nixos.bookorbit = {
    config,
    pkgs,
    ...
  }: let
    version = "3.0.0";
    postgresVersion = "pg18";

    subdomain = "books";
    port = "20040";
    internalPort = "3000";
    url = "https://${subdomain}.${config.internal.homelab.domain}";

    puid = "1000";
    pgid = "1000";

    inherit (config.virtualisation.quadlet) pods;
    inherit (self.lib.podman) svc volume;
  in {
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
      };
    };

    virtualisation.quadlet = {
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
            environmentFiles = [config.sops.templates."bookorbit-env".path];
            image = "docker.io/pgvector/pgvector:${postgresVersion}";
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
            environmentFiles = [config.sops.templates."bookorbit-env".path];

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

            image = "ghcr.io/bookorbit/bookorbit:${version}";
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
            ExecStartPre = "${pkgs.coreutils}/bin/chown ${puid}:${pgid} ${volume "bookorbit-books"} ${volume "bookorbit-data"}";
            Restart = "always";
          };

          unitConfig = {
            After = map svc ["bookorbit-db"];
            Description = "BookOrbit Library Manager";
            Requires = map svc ["bookorbit-db"];
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
