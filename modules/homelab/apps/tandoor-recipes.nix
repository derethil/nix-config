{self, ...}: let
  appImage = "docker.io/vabene1111/recipes";
  appVersion = "2.7.3";
  appDigest = "sha256:73bb55c3096b9badd901717e298e025015ae3a264fecfb21a2a9fff72109f4f6";

  postgresImage = "docker.io/library/postgres";
  postgresVersion = "18.7-alpine";
  postgresDigest = "sha256:b6972e1115a4ff8eba5d7f7d19184926d1e16d7d1136ae1e1a7ebf286da0f015";

  subdomain = "recipes";
  port = "20010";
  internalPort = "8080";

  inherit (self.lib.podman) svc user volume;
in {
  flake.modules = self.factory.container-app {
    name = "tandoor-recipes";

    nixos = {config, ...}: {
      imports = [
        self.modules.nixos.gatus-options
        self.modules.nixos.ingress
        self.modules.nixos.oidc-options
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
                  redir * ${config.internal.homelab.oidc.endSessionUrl}
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

            SOCIALACCOUNT_PROVIDERS=${self.lib.oidc.allauthProvider {
              inherit (config.internal.homelab.oidc) discoveryUrl name providerId;
              clientId = config.sops.placeholder."serve/tandoor/oidc/client_id";
              clientSecret = config.sops.placeholder."serve/tandoor/oidc/client_secret";
            }}
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

      host = "${subdomain}.${osConfig.internal.homelab.domain}";
      envFile = osConfig.sops.templates."tandoor-recipes-env".path;
    in {
      containers = {
        tandoor-db = self.lib.quadlet.mkQuadletPostgresPod config "tandoor" {
          containerConfig = {
            environmentFiles = [envFile];
            image = "${postgresImage}:${postgresVersion}@${postgresDigest}";
          };
        };

        tandoor-web = {
          containerConfig = {
            addCapabilities = [
              "CHOWN"
              "SETGID"
              "SETUID"
            ];

            dropCapabilities = ["ALL"];
            environmentFiles = [envFile];

            environments = {
              ACCOUNT_EMAIL_VERIFICATION = "none";
              AI_ALLOWED_URLS = "https://openrouter.ai/api/v1";
              ALLOWED_HOSTS = "*";
              CSRF_TRUSTED_ORIGINS = "https://${host}";
              DB_ENGINE = "django.db.backends.postgresql";
              POSTGRES_HOST = "localhost";
              POSTGRES_PORT = "5432";
              SECURE_PROXY_SSL_HEADER = "HTTP_X_FORWARDED_PROTO,https";
              SOCIALACCOUNT_EMAIL_VERIFICATION = "none";
              SOCIALACCOUNT_ONLY = "1";
              SOCIAL_PROVIDERS = "allauth.socialaccount.providers.openid_connect";
              TANDOOR_PORT = internalPort;
            };

            image = "${appImage}:${appVersion}@${appDigest}";
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
            Wants = map svc ["tandoor-db"];
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
