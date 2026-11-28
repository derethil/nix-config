{
  self,
  lib,
  ...
}: let
  inherit (lib) getExe' mkMerge;

  appImage = "ghcr.io/mrblomblo/blombooru";
  appVersion = "2.0.0";
  appDigest = "sha256:c2f52e55b289c6b25edc88bf9b4546319d30278bd207220ffa7b0aa4abfcb6fb";

  postgresImage = "docker.io/library/postgres";
  postgresVersion = "19.0-alpine";
  postgresDigest = "sha256:cac45fb483caee3668946088a1c0532db89d5285c28dbfeac889b4068296e06f";

  redisImage = "docker.io/library/redis";
  redisVersion = "8.10.3-alpine";
  redisDigest = "sha256:7958cfbb9d152f87dadfbc89f1b0b15938f0b81ff8982feb327476f4911935c3";

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
        blombooru-db = self.lib.quadlet.mkQuadletPostgresPod config "blombooru" {
          containerConfig = {
            environmentFiles = [envFile];
            image = "${postgresImage}:${postgresVersion}@${postgresDigest}";
          };
        };

        blombooru-redis = {
          containerConfig = mkMerge [
            (self.lib.quadlet.mkHealthCheck ''redis-cli -a "$REDIS_PASSWORD" ping | grep -q PONG'' {})

            {
              dropCapabilities = ["ALL"];
              environmentFiles = [envFile];
              exec = ["sh" "-c" ''exec redis-server --save 60 1 --loglevel warning --requirepass "$REDIS_PASSWORD"''];
              image = "${redisImage}:${redisVersion}@${redisDigest}";
              noNewPrivileges = true;
              pod = pods.blombooru.ref;
              pull = "newer";
              user = "redis";
              volumes = ["blombooru-redis:/data"];
            }
          ];

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
            Wants = map svc ["blombooru-db" "blombooru-redis"];
          };
        };
      };

      pods.blombooru = self.lib.quadlet.mkQuadletPod port internalPort;

      volumes = {
        blombooru-data = {};
        blombooru-db = {};
        blombooru-media = {};
        blombooru-redis = {};
      };
    };
  };
}
