{self, ...}: {
  flake.modules.nixos.blombooru = {config, ...}: let
    version = "1.40.0";
    subdomain = "stash";
    port = "20020";
    internalPort = "8000";
    inherit (config.virtualisation.quadlet) pods;
  in {
    imports = [
      self.modules.nixos.homelab
      self.modules.nixos.quadlet
      self.modules.nixos.secrets
    ];

    internal.homelab.services.blombooru = {
      inherit subdomain port;
    };

    sops = {
      secrets = {
        "services/homelab/blombooru/postgres_password" = {};
        "services/homelab/blombooru/redis_password" = {};
      };

      templates."blombooru-env" = {
        mode = "0400";
        content = ''
          POSTGRES_DB=blombooru
          POSTGRES_USER=blombooru
          POSTGRES_PASSWORD=${config.sops.placeholder."services/homelab/blombooru/postgres_password"}
          REDIS_PASSWORD=${config.sops.placeholder."services/homelab/blombooru/redis_password"}
        '';
      };
    };

    virtualisation.quadlet = {
      pods.blombooru = {
        podConfig = {
          publishPorts = ["127.0.0.1:${port}:${internalPort}"];
          exitPolicy = "continue";
        };
        autoStart = true;
      };

      containers = {
        blombooru-web = {
          containerConfig = {
            pod = pods.blombooru.ref;
            image = "ghcr.io/mrblomblo/blombooru:${version}";
            pull = "newer";
            environmentFiles = [config.sops.templates."blombooru-env".path];
            environments = {
              APP_NAME = "Blombooru";
              APP_PORT = internalPort;
              UVICORN_PORT = internalPort;
              POSTGRES_HOST = "localhost";
              POSTGRES_PORT = "5432";
              REDIS_ENABLED = "true";
              REDIS_HOST = "localhost";
              REDIS_PORT = "6379";
              REDIS_DB = "0";
              # cache WD tagger models in the persisted data volume so they
              # survive container recreation instead of re-downloading
              HF_HOME = "/app/data/huggingface";
            };
            volumes = [
              "blombooru-media:/app/media"
              "blombooru-data:/app/data"
            ];
            dropCapabilities = ["ALL"];
            addCapabilities = [
              "CHOWN"
              "SETGID"
              "SETUID"
            ];
            noNewPrivileges = true;
          };
          unitConfig = {
            Description = "Blombooru Media Tagging";
            After = ["blombooru-db.service" "blombooru-redis.service"];
            Requires = ["blombooru-db.service" "blombooru-redis.service"];
          };
          serviceConfig = {
            Restart = "always";
          };
        };

        blombooru-db = {
          containerConfig = {
            pod = pods.blombooru.ref;
            image = "docker.io/library/postgres:17";
            pull = "newer";
            environmentFiles = [config.sops.templates."blombooru-env".path];
            volumes = [
              "blombooru-db:/var/lib/postgresql/data"
            ];
            dropCapabilities = ["ALL"];
            addCapabilities = [
              "CHOWN"
              "DAC_READ_SEARCH"
              "FOWNER"
              "SETGID"
              "SETUID"
            ];
            noNewPrivileges = true;
          };
          unitConfig = {
            Description = "Blombooru PostgreSQL Database";
          };
          serviceConfig = {
            Restart = "always";
          };
        };

        blombooru-redis = {
          containerConfig = {
            pod = pods.blombooru.ref;
            image = "docker.io/library/redis:7-alpine";
            pull = "newer";
            user = "redis";
            environmentFiles = [config.sops.templates."blombooru-env".path];
            exec = [
              "sh"
              "-c"
              ''exec redis-server --save 60 1 --loglevel warning --requirepass "$REDIS_PASSWORD"''
            ];
            volumes = [
              "blombooru-redis:/data"
            ];
            dropCapabilities = ["ALL"];
            noNewPrivileges = true;
          };
          unitConfig = {
            Description = "Blombooru Redis Cache";
          };
          serviceConfig = {
            Restart = "always";
          };
        };
      };

      volumes = {
        blombooru-media = {};
        blombooru-data = {};
        blombooru-db = {};
        blombooru-redis = {};
      };
    };
  };
}
