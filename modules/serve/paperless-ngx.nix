{self, ...}: {
  flake.modules.nixos.paperless-ngx = {config, ...}: let
    version = "3.0.5";
    subdomain = "documents";
    port = "20050";
    internalPort = "8000";
    host = "${subdomain}.${config.internal.homelab.domain}";
    inherit (config.virtualisation.quadlet) pods;
    inherit (self.lib) podmanVolume;
  in {
    imports = [
      self.modules.nixos.ingress
      self.modules.nixos.quadlet
      self.modules.nixos.restic
      self.modules.nixos.secrets
    ];

    internal.homelab = {
      backups.paperless = {
        onCalendar = "02:00";

        paths = [
          (podmanVolume "paperless-data")
          (podmanVolume "paperless-media")
          (podmanVolume "paperless-consume")
        ];

        postgres = [
          {
            container = "paperless-db";
            database = "paperless";
            user = "paperless";
          }
        ];
      };

      ingress.paperless = {
        inherit port subdomain;
      };
    };

    sops = {
      secrets = {
        "serve/paperless/postgres_password" = {};
        "serve/paperless/secret_key" = {};
      };

      templates."paperless-ngx-env" = {
        mode = "0400";
        content = ''
          POSTGRES_DB=paperless
          POSTGRES_USER=paperless
          POSTGRES_PASSWORD=${config.sops.placeholder."serve/paperless/postgres_password"}
          PAPERLESS_DBPASS=${config.sops.placeholder."serve/paperless/postgres_password"}
          PAPERLESS_SECRET_KEY=${config.sops.placeholder."serve/paperless/secret_key"}
        '';
      };
    };

    virtualisation.quadlet = {
      containers = {
        paperless-broker = {
          containerConfig = {
            dropCapabilities = ["ALL"];
            image = "docker.io/valkey/valkey:9-alpine";
            noNewPrivileges = true;
            pod = pods.paperless.ref;
            pull = "newer";
            user = "valkey";
            volumes = ["paperless-broker:/data"];
          };

          serviceConfig.Restart = "always";
          unitConfig.Description = "Paperless-ngx Valkey Broker";
        };

        paperless-db = {
          containerConfig = {
            addCapabilities = [
              "CHOWN"
              "DAC_READ_SEARCH"
              "FOWNER"
              "SETGID"
              "SETUID"
            ];

            dropCapabilities = ["ALL"];
            environmentFiles = [config.sops.templates."paperless-ngx-env".path];
            image = "docker.io/library/postgres:17-alpine";
            noNewPrivileges = true;
            pod = pods.paperless.ref;
            pull = "newer";
            volumes = ["paperless-db:/var/lib/postgresql/data"];
          };

          serviceConfig.Restart = "always";
          unitConfig.Description = "Paperless-ngx PostgreSQL Database";
        };

        paperless-web = {
          containerConfig = {
            addCapabilities = [
              "CHOWN"
              "DAC_OVERRIDE"
              "FOWNER"
              "SETGID"
              "SETUID"
            ];

            dropCapabilities = ["ALL"];
            environmentFiles = [config.sops.templates."paperless-ngx-env".path];

            environments = {
              PAPERLESS_DBENGINE = "postgresql";
              PAPERLESS_DBHOST = "localhost";
              PAPERLESS_DBNAME = "paperless";
              PAPERLESS_DBPORT = "5432";
              PAPERLESS_DBUSER = "paperless";
              PAPERLESS_REDIS = "redis://localhost:6379";
              PAPERLESS_URL = "https://${host}";
            };

            image = "ghcr.io/paperless-ngx/paperless-ngx:${version}";
            pod = pods.paperless.ref;
            pull = "newer";

            volumes = [
              "paperless-data:/usr/src/paperless/data"
              "paperless-media:/usr/src/paperless/media"
              "paperless-consume:/usr/src/paperless/consume"
            ];
          };

          serviceConfig.Restart = "always";

          unitConfig = {
            After = ["paperless-db.service" "paperless-broker.service"];
            Description = "Paperless-ngx Document Manager";
            Requires = ["paperless-db.service" "paperless-broker.service"];
          };
        };
      };

      pods.paperless = {
        autoStart = true;

        podConfig = {
          exitPolicy = "continue";
          publishPorts = ["127.0.0.1:${port}:${internalPort}"];
        };
      };

      volumes = {
        paperless-broker = {};
        paperless-consume = {};
        paperless-data = {};
        paperless-db = {};
        paperless-media = {};
      };
    };
  };
}
