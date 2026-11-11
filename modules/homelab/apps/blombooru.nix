{
  self,
  lib,
  ...
}: let
  inherit (lib) getExe';

  appImage = "ghcr.io/mrblomblo/blombooru";
  appVersion = "1.40.0";
  appDigest = "sha256:179043295207b9ee86c109b706e10027b4c14fbc973059c32ec909ca032f9328";

  postgresImage = "docker.io/library/postgres";
  postgresVersion = "17-alpine";
  postgresDigest = "sha256:e5d2edd28b1f8d40a0a6c0c9cdc545b19b56a0d5d88f94bc11a97d970d4700d0";

  redisImage = "docker.io/library/redis";
  redisVersion = "7-alpine";
  redisDigest = "sha256:7b1753b4c5ad8458906c272a8132b8c15f5557b000379eb115fb239706a384b7";

  subdomain = "stash";
  port = "20020";
  internalPort = "8000";

  inherit (self.lib.podman) asUser svc user volume;
in {
  flake.modules = self.factory.container-app {
    name = "blombooru";

    nixos = {
      config,
      pkgs,
      ...
    }: {
      imports = [
        self.modules.nixos.gatus-options
        self.modules.nixos.ingress
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
            # REDIS_PASSWORD is expanded by the shell inside the container, which
            # inherits it from the container's env-file -- not by this script.
            hooks.afterRestore = ''
              echo "==> Flushing Redis cache..."
              ${asUser pkgs "${getExe' pkgs.podman "podman"} exec"} blombooru-redis sh -c 'redis-cli -a "$REDIS_PASSWORD" FLUSHALL'
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

      envFile = osConfig.sops.templates."blombooru-env".path;
    in {
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
            environmentFiles = [envFile];
            image = "${postgresImage}:${postgresVersion}@${postgresDigest}";
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
            environmentFiles = [envFile];

            exec = [
              "sh"
              "-c"
              ''exec redis-server --save 60 1 --loglevel warning --requirepass "$REDIS_PASSWORD"''
            ];

            image = "${redisImage}:${redisVersion}@${redisDigest}";
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
            environmentFiles = [envFile];

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

            image = "${appImage}:${appVersion}@${appDigest}";
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
