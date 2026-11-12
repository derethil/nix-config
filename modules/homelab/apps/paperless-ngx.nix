{self, ...}: let
  appImage = "ghcr.io/paperless-ngx/paperless-ngx";
  appVersion = "3.4.2";
  appDigest = "sha256:d704e84f88300eb6ab001ab15720a2330ff99169cf9f94d6b8fcc44b63a84c84";

  postgresImage = "docker.io/library/postgres";
  postgresVersion = "17-alpine";
  postgresDigest = "sha256:e5d2edd28b1f8d40a0a6c0c9cdc545b19b56a0d5d88f94bc11a97d970d4700d0";

  valkeyImage = "docker.io/valkey/valkey";
  valkeyVersion = "9-alpine";
  valkeyDigest = "sha256:bf09d58e96d6b4524a15396b65b242bbe18beebbcc15a04d8ee75ddac62fae0b";

  subdomain = "documents";
  port = "20050";
  internalPort = "8000";

  inherit (self.lib.podman) svc user volume;
in {
  flake.modules = self.factory.container-app {
    name = "paperless-ngx";

    nixos = {config, ...}: {
      imports = [
        self.modules.nixos.gatus-options
        self.modules.nixos.hydroxide
        self.modules.nixos.ingress
        self.modules.nixos.oidc-options
        self.modules.nixos.quadlet
        self.modules.nixos.restic
        self.modules.nixos.secrets
      ];

      internal.homelab = {
        backups.paperless = {
          databases.postgres = [
            {
              container = "paperless-db";
              database = "paperless";
              user = "paperless";
            }
          ];

          files.paths = map volume ["paperless-data" "paperless-media" "paperless-consume"];

          restore.services = {
            afterRestore = map svc ["paperless-broker" "paperless-web"];
            afterSync = map svc ["paperless-pod" "paperless-db"];
            stop = map svc ["paperless-web" "paperless-broker" "paperless-db" "paperless-pod"];
          };
        };

        gatus.endpoints.paperless = {};

        ingress.paperless = {
          inherit port subdomain;
        };
      };

      sops = {
        secrets = {
          "serve/paperless/oidc/client_id" = {};
          "serve/paperless/oidc/client_secret" = {};
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
            PAPERLESS_SOCIALACCOUNT_PROVIDERS=${self.lib.oidc.allauthProvider {
              inherit (config.internal.homelab.oidc) discoveryUrl name providerId;
              clientId = config.sops.placeholder."serve/paperless/oidc/client_id";
              clientSecret = config.sops.placeholder."serve/paperless/oidc/client_secret";
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
      envFile = osConfig.sops.templates."paperless-ngx-env".path;
    in {
      containers = {
        paperless-broker = {
          containerConfig = {
            dropCapabilities = ["ALL"];
            image = "${valkeyImage}:${valkeyVersion}@${valkeyDigest}";
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
            environmentFiles = [envFile];
            image = "${postgresImage}:${postgresVersion}@${postgresDigest}";
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
            environmentFiles = [envFile];

            environments = {
              PAPERLESS_ACCOUNT_ALLOW_SIGNUPS = "false";
              PAPERLESS_APPS = "allauth.socialaccount.providers.openid_connect";
              PAPERLESS_DBENGINE = "postgresql";
              PAPERLESS_DBHOST = "localhost";
              PAPERLESS_DBNAME = "paperless";
              PAPERLESS_DBPORT = "5432";
              PAPERLESS_DBUSER = "paperless";
              PAPERLESS_DISABLE_REGULAR_LOGIN = "1";
              PAPERLESS_LOGOUT_REDIRECT_URL = osConfig.internal.homelab.oidc.endSessionUrl;
              PAPERLESS_REDIRECT_LOGIN_TO_SSO = "1";
              PAPERLESS_REDIS = "redis://localhost:6379";
              PAPERLESS_SOCIAL_AUTO_SIGNUP = "1";
              PAPERLESS_URL = "https://${host}";
            };

            image = "${appImage}:${appVersion}@${appDigest}";
            pod = pods.paperless.ref;
            pull = "newer";

            volumes = [
              "paperless-data:/usr/src/paperless/data"
              "paperless-media:/usr/src/paperless/media"
              "paperless-consume:/usr/src/paperless/consume"
              "paperless-export:/usr/src/paperless/export"
            ];
          };

          serviceConfig.Restart = "always";

          unitConfig = {
            After = map svc ["paperless-db" "paperless-broker"];
            Description = "Paperless-ngx Document Manager";
            Wants = map svc ["paperless-db" "paperless-broker"];
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
        paperless-export = {};
        paperless-media = {};
      };
    };
  };
}
