{self, ...}: {
  flake.modules.nixos.tandoor-recipes = {config, ...}: let
    version = "2.6.13";
    host = "recipes.local";
    servicePort = toString config.internal.homelab.ports.tandoor;
    internalPort = "8080";
    inherit (config.virtualisation.quadlet) pods;
  in {
    imports = [
      self.modules.nixos.ports
      self.modules.nixos.quadlet
      self.modules.nixos.caddy
      self.modules.nixos.secrets
    ];

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

    # TODO: Replace with a proper DNS module
    networking.hosts."127.0.0.1" = [host];

    services.caddy.virtualHosts."http://${host}" = {
      extraConfig = ''
        reverse_proxy 127.0.0.1:${servicePort}
      '';
    };

    virtualisation.quadlet = {
      pods.tandoor-recipes = {
        podConfig.publishPorts = ["127.0.0.1:${servicePort}:${internalPort}"];
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
              CSRF_TRUSTED_ORIGINS = "http://${host}";
              SECURE_PROXY_SSL_HEADER = "HTTP_X_FORWARDED_PROTO,https";
            };
            volumes = [
              "/etc/localtime:/etc/localtime:ro"
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
