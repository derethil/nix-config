{self, ...}: {
  flake.modules.nixos.tandoor-recipes = {config, ...}: let
    version = "2.6.13";
    subdomain = "recipes";
    port = "20010";
    internalPort = "8080";
    host = "${subdomain}.${config.internal.homelab.domain}";
    inherit (config.virtualisation.quadlet) pods;
  in {
    imports = [
      self.modules.nixos.homelab
      self.modules.nixos.quadlet
      self.modules.nixos.secrets
    ];

    internal.homelab.services.tandoor = {
      inherit subdomain port;
    };

    sops = {
      secrets = {
        "services/homelab/tandoor/postgres_password" = {};
        "services/homelab/tandoor/secret_key" = {};
      };

      templates."tandoor-recipes-env" = {
        mode = "0400";
        content = ''
          POSTGRES_PASSWORD=${config.sops.placeholder."services/homelab/tandoor/postgres_password"}
          POSTGRES_USER=djangodb
          POSTGRES_DB=djangodb
          SECRET_KEY=${config.sops.placeholder."services/homelab/tandoor/secret_key"}
        '';
      };
    };

    virtualisation.quadlet = {
      pods.tandoor-recipes = {
        podConfig = {
          publishPorts = ["127.0.0.1:${port}:${internalPort}"];

          # let each container handle its own restart policy
          # so that the pod doesn't restart if one container fails
          exitPolicy = "continue";
        };
        autoStart = true;
      };

      containers = {
        tandoor = {
          containerConfig = {
            pod = pods.tandoor-recipes.ref;
            image = "docker.io/vabene1111/recipes:${version}";
            pull = "newer";
            environmentFiles = [config.sops.templates."tandoor-recipes-env".path];
            environments = {
              TANDOOR_PORT = internalPort;
              DB_ENGINE = "django.db.backends.postgresql";
              POSTGRES_HOST = "localhost";
              POSTGRES_PORT = "5432";
              ALLOWED_HOSTS = "*";
              CSRF_TRUSTED_ORIGINS = "https://${host}";
              SECURE_PROXY_SSL_HEADER = "HTTP_X_FORWARDED_PROTO,https";
            };
            volumes = [
              "tandoor-media:/opt/recipes/mediafiles"
              "tandoor-static:/opt/recipes/staticfiles"
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
            Description = "Tandoor Recipes Manager";
            After = ["tandoordb.service"];
            Requires = ["tandoordb.service"];
          };
          serviceConfig = {
            Restart = "always";
          };
        };

        tandoordb = {
          containerConfig = {
            pod = pods.tandoor-recipes.ref;
            image = "docker.io/library/postgres:17-alpine";
            pull = "newer";
            environmentFiles = [config.sops.templates."tandoor-recipes-env".path];
            volumes = [
              "tandoor-db:/var/lib/postgresql/data"
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
            Description = "Tandoor Recipes PostgreSQL Database";
          };
          serviceConfig = {
            Restart = "always";
          };
        };
      };

      volumes = {
        tandoor-media = {};
        tandoor-static = {};
        tandoor-db = {};
      };
    };
  };
}
