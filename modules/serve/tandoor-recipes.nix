{self, ...}: {
  flake.modules.nixos.tandoor-recipes = {config, ...}: let
    version = "2.6.13";
    postgresVersion = "17-alpine";

    subdomain = "recipes";
    port = "20010";
    internalPort = "8080";
    host = "${subdomain}.${config.internal.homelab.domain}";

    inherit (config.virtualisation.quadlet) pods;
    inherit (self.lib.podman) svc volume;
  in {
    imports = [
      self.modules.nixos.gatus-options
      self.modules.nixos.pocket-id
      self.modules.nixos.ingress
      self.modules.nixos.quadlet
      self.modules.nixos.restic
      self.modules.nixos.secrets
    ];

    internal.homelab = {
      backups.tandoor = {
        databases.postgres = [
          {
            container = "tandoor-db";
            database = "djangodb";
            user = "djangodb";
          }
        ];

        files.paths = map volume ["tandoor-media"];

        restore.services = {
          afterRestore = map svc ["tandoor-web"];
          afterSync = map svc ["tandoor-pod" "tandoor-db"];
          stop = map svc ["tandoor-web" "tandoor-db" "tandoor-pod"];
        };
      };

      gatus.endpoints.tandoor = {};

      ingress.tandoor = {
        inherit port subdomain;

        # HACK: Tandoor hardcodes its post-logout redirect, but logs out on GET. Hit both on the logout endpoint
        caddy.extraConfig = ''
          handle /accounts/logout* {
            forward_auth 127.0.0.1:${port} {
              uri /accounts/logout/
              @done status 2xx 3xx
              handle_response @done {
                redir * ${self.lib.homelab.logoutRedirectUrl config}
              }
            }
          }
        '';
      };
    };

    sops = {
      secrets = {
        "serve/tandoor/oidc/client_id" = {};
        "serve/tandoor/oidc/client_secret" = {};
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

          SOCIALACCOUNT_PROVIDERS={"openid_connect":{"APPS":[{"provider_id":"pocket-id","name":"Pocket ID","client_id":"${config.sops.placeholder."serve/tandoor/oidc/client_id"}","secret":"${config.sops.placeholder."serve/tandoor/oidc/client_secret"}","settings":{"server_url":"https://auth.${config.internal.homelab.domain}/.well-known/openid-configuration"}}]}}
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
            volumes = ["tandoor-db:/var/lib/postgresql/data"];
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
              HIDE_LOGIN_FORM = "1";
              POSTGRES_HOST = "localhost";
              POSTGRES_PORT = "5432";
              SECURE_PROXY_SSL_HEADER = "HTTP_X_FORWARDED_PROTO,https";
              SOCIALACCOUNT_LOGIN_ON_GET = "1";
              SOCIALACCOUNT_ONLY = "1";
              SOCIAL_PROVIDERS = "allauth.socialaccount.providers.openid_connect";
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
            After = map svc ["tandoor-db"];
            Description = "Tandoor Recipes Manager";
            Requires = map svc ["tandoor-db"];
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
