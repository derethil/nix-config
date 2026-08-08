{self, ...}: {
  flake.modules.nixos.tandoor-recipes = {config, ...}: let
    version = "2.6.13";
    postgresVersion = "17-alpine";

    subdomain = "recipes";
    port = "20010";
    internalPort = "8080";
    host = "${subdomain}.${config.internal.homelab.domain}";

    inherit (config.virtualisation.quadlet) pods;
    inherit (self.lib) podmanVolume;
  in {
    imports = [
      self.modules.nixos.gatus-options
      self.modules.nixos.ingress
      self.modules.nixos.quadlet
      self.modules.nixos.restic
      self.modules.nixos.secrets
    ];

    internal.homelab = {
      backups.tandoor = {
        paths = [(podmanVolume "tandoor-media")];

        postgres = [
          {
            container = "tandoor-db";
            database = "djangodb";
            user = "djangodb";
          }
        ];

        restore = {
          startAfter = ["tandoor-web.service"];
          startBefore = ["tandoor-pod.service" "tandoor-db.service"];
          stopServices = ["tandoor-web.service" "tandoor-db.service" "tandoor-pod.service"];
        };
      };

      gatus.endpoints.tandoor = {};

      ingress.tandoor = {
        inherit port subdomain;
      };
    };

    sops = {
      secrets = {
        "serve/tandoor/postgres_password" = {};
        "serve/tandoor/secret_key" = {};
      };

      templates."tandoor-recipes-env" = {
        mode = "0400";
        content = ''
          POSTGRES_PASSWORD=${config.sops.placeholder."serve/tandoor/postgres_password"}
          POSTGRES_USER=djangodb
          POSTGRES_DB=djangodb
          SECRET_KEY=${config.sops.placeholder."serve/tandoor/secret_key"}
        '';
      };
    };

    virtualisation.quadlet = {
      containers = {
        tandoor-db = {
          containerConfig = {
            addCapabilities = [
              "CHOWN"
              "DAC_READ_SEARCH"
              "FOWNER"
              "SETGID"
              "SETUID"
            ];

            dropCapabilities = ["ALL"];
            environmentFiles = [config.sops.templates."tandoor-recipes-env".path];
            image = "docker.io/library/postgres:${postgresVersion}";
            noNewPrivileges = true;
            pod = pods.tandoor.ref;
            pull = "newer";

            volumes = [
              "tandoor-db:/var/lib/postgresql/data"
            ];
          };

          serviceConfig.Restart = "always";
          unitConfig.Description = "Tandoor Recipes PostgreSQL Database";
        };

        tandoor-web = {
          containerConfig = {
            addCapabilities = [
              "CHOWN"
              "SETGID"
              "SETUID"
            ];

            dropCapabilities = ["ALL"];
            environmentFiles = [config.sops.templates."tandoor-recipes-env".path];

            environments = {
              AI_ALLOWED_URLS = "https://openrouter.ai/api/v1";
              ALLOWED_HOSTS = "*";
              CSRF_TRUSTED_ORIGINS = "https://${host}";
              DB_ENGINE = "django.db.backends.postgresql";
              POSTGRES_HOST = "localhost";
              POSTGRES_PORT = "5432";
              SECURE_PROXY_SSL_HEADER = "HTTP_X_FORWARDED_PROTO,https";
              TANDOOR_PORT = internalPort;
            };

            image = "docker.io/vabene1111/recipes:${version}";
            noNewPrivileges = true;
            pod = pods.tandoor.ref;
            pull = "newer";

            volumes = [
              "tandoor-media:/opt/recipes/mediafiles"
              "tandoor-static:/opt/recipes/staticfiles"
            ];
          };

          serviceConfig.Restart = "always";

          unitConfig = {
            After = ["tandoor-db.service"];
            Description = "Tandoor Recipes Manager";
            Requires = ["tandoor-db.service"];
          };
        };
      };

      pods.tandoor = {
        autoStart = true;

        podConfig = {
          exitPolicy = "continue";
          publishPorts = ["127.0.0.1:${port}:${internalPort}"];
        };
      };

      volumes = {
        tandoor-db = {};
        tandoor-media = {};
        tandoor-static = {};
      };
    };
  };
}
