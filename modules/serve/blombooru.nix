{self, ...}: {
  flake.modules.nixos.blombooru = {config, ...}: let
    version = "1.40.0";
    postgresVersion = "17-alpine";
    redisVersion = "7-alpine";

    subdomain = "stash";
    port = "20020";
    internalPort = "8000";

    inherit (config.virtualisation.quadlet) pods;
    inherit (self.lib.podman) svc volume;
  in {
    imports = [
      self.modules.nixos.gatus-options
      self.modules.nixos.ingress
      self.modules.nixos.oauth2-proxy
      self.modules.nixos.quadlet
      self.modules.nixos.restic
      self.modules.nixos.secrets
    ];

    internal.homelab = {
      backups.blombooru = {
        databases.postgres = [
          {
            container = "blombooru-db";
            database = "blombooru";
            user = "blombooru";
          }
        ];

        files = {
          exclude = ["${volume "blombooru-data"}/huggingface"];
          paths = map volume ["blombooru-data" "blombooru-media"];
        };

        restore = {
          hooks.afterRestore = ''
            echo "==> Flushing Redis cache..."
            sudo podman exec blombooru-redis sh -c 'redis-cli -a "$REDIS_PASSWORD" FLUSHALL'
          '';

          services = {
            afterRestore = map svc ["blombooru-redis" "blombooru-web"];
            afterSync = map svc ["blombooru-pod" "blombooru-db"];
            stop = map svc ["blombooru-web" "blombooru-redis" "blombooru-db" "blombooru-pod"];
          };
        };
      };

      gatus.endpoints.blombooru = {};

      ingress.blombooru = {
        inherit port subdomain;
        caddy.protect = true;
      };
    };

    sops = {
      secrets = {
        "serve/blombooru/postgres_password" = {};
        "serve/blombooru/redis_password" = {};
      };

      templates."blombooru-env" = {
        mode = "0400";
        content = ''
          POSTGRES_DB=blombooru
          POSTGRES_USER=blombooru
          POSTGRES_PASSWORD=${config.sops.placeholder."serve/blombooru/postgres_password"}
          REDIS_PASSWORD=${config.sops.placeholder."serve/blombooru/redis_password"}
        '';
      };
    };

    virtualisation.quadlet = {
      containers = {
        blombooru-db = {
          containerConfig = {
            addCapabilities = [
              "CHOWN"
              "DAC_READ_SEARCH"
              "FOWNER"
              "SETGID"
              "SETUID"
            ];

            dropCapabilities = ["ALL"];
            environmentFiles = [config.sops.templates."blombooru-env".path];
            image = "docker.io/library/postgres:${postgresVersion}";
            noNewPrivileges = true;
            pod = pods.blombooru.ref;
            pull = "newer";
            volumes = ["blombooru-db:/var/lib/postgresql/data"];
          };

          serviceConfig.Restart = "always";
          unitConfig.Description = "Blombooru PostgreSQL Database";
        };

        blombooru-redis = {
          containerConfig = {
            dropCapabilities = ["ALL"];
            environmentFiles = [config.sops.templates."blombooru-env".path];

            exec = [
              "sh"
              "-c"
              ''exec redis-server --save 60 1 --loglevel warning --requirepass "$REDIS_PASSWORD"''
            ];

            image = "docker.io/library/redis:${redisVersion}";
            noNewPrivileges = true;
            pod = pods.blombooru.ref;
            pull = "newer";
            user = "redis";
            volumes = ["blombooru-redis:/data"];
          };

          serviceConfig.Restart = "always";
          unitConfig.Description = "Blombooru Redis Cache";
        };

        blombooru-web = {
          containerConfig = {
            addCapabilities = [
              "CHOWN"
              "SETGID"
              "SETUID"
            ];

            dropCapabilities = ["ALL"];
            environmentFiles = [config.sops.templates."blombooru-env".path];

            environments = {
              APP_NAME = "Blombooru";
              APP_PORT = internalPort;
              # cache WD tagger models in the persisted data volume so they
              # survive container recreation instead of re-downloading
              HF_HOME = "/app/data/huggingface";
              POSTGRES_HOST = "localhost";
              POSTGRES_PORT = "5432";
              REDIS_DB = "0";
              REDIS_ENABLED = "true";
              REDIS_HOST = "localhost";
              REDIS_PORT = "6379";
              UVICORN_PORT = internalPort;
            };

            image = "ghcr.io/mrblomblo/blombooru:${version}";
            noNewPrivileges = true;
            pod = pods.blombooru.ref;
            pull = "newer";

            volumes = [
              "blombooru-data:/app/data"
              "blombooru-media:/app/media"
            ];
          };

          serviceConfig.Restart = "always";

          unitConfig = {
            After = map svc ["blombooru-db" "blombooru-redis"];
            Description = "Blombooru Media Tagging";
            Requires = map svc ["blombooru-db" "blombooru-redis"];
          };
        };
      };

      pods.blombooru = {
        autoStart = true;

        podConfig = {
          exitPolicy = "continue";
          publishPorts = ["127.0.0.1:${port}:${internalPort}"];
        };
      };

      volumes = {
        blombooru-data = {};
        blombooru-db = {};
        blombooru-media = {};
        blombooru-redis = {};
      };
    };
  };
}
