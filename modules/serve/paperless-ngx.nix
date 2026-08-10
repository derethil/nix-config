{self, ...}: {
  flake.modules.nixos.paperless-ngx = {config, ...}: let
    version = "3.0.5";
    postgresVersion = "17-alpine";
    valkeyVersion = "9-alpine";

    subdomain = "documents";
    port = "20050";
    internalPort = "8000";
    host = "${subdomain}.${config.internal.homelab.domain}";

    inherit (config.virtualisation.quadlet) pods;
    inherit (self.lib.podman) svc volume;
  in {
    imports = [
      self.modules.nixos.gatus-options
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
      };
    };

    virtualisation.quadlet = {
      containers = {
        paperless-broker = {
          containerConfig = {
            dropCapabilities = ["ALL"];
            image = "docker.io/valkey/valkey:${valkeyVersion}";
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
            environmentFiles = [config.sops.templates."paperless-ngx-env".path];
            image = "docker.io/library/postgres:${postgresVersion}";
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
            environmentFiles = [config.sops.templates."paperless-ngx-env".path];

            environments = {
              PAPERLESS_ACCOUNT_ALLOW_SIGNUPS = "false";
              PAPERLESS_APPS = "allauth.socialaccount.providers.openid_connect";
              PAPERLESS_DBENGINE = "postgresql";
              PAPERLESS_DBHOST = "localhost";
              PAPERLESS_DBNAME = "paperless";
              PAPERLESS_DBPORT = "5432";
              PAPERLESS_DBUSER = "paperless";
              PAPERLESS_DISABLE_REGULAR_LOGIN = "1";
              PAPERLESS_LOGOUT_REDIRECT_URL = config.internal.homelab.oidc.endSessionUrl;
              PAPERLESS_REDIRECT_LOGIN_TO_SSO = "1";
              PAPERLESS_REDIS = "redis://localhost:6379";
              PAPERLESS_SOCIAL_AUTO_SIGNUP = "1";
              PAPERLESS_URL = "https://${host}";
            };

            image = "ghcr.io/paperless-ngx/paperless-ngx:${version}";
            pod = pods.paperless.ref;
            pull = "newer";

            volumes = [
              "paperless-data:/usr/src/paperless/data"
              "paperless-media:/usr/src/paperless/media"
              "paperless-consume:/usr/src/paperless/consume"
            ];
          };

          serviceConfig.Restart = "always";

          unitConfig = {
            After = map svc ["paperless-db" "paperless-broker"];
            Description = "Paperless-ngx Document Manager";
            Requires = map svc ["paperless-db" "paperless-broker"];
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
        paperless-media = {};
      };
    };
  };
}
