{self, ...}: let
  appImage = "ghcr.io/seanmorley15/adventurelog";
  appVersion = "v0.13.1";
  appDigest = "sha256:67ff66e4a2b46b3ca4806a3ecb47cb71c42443ea2d88c18e1ea3dba3ae0d2cf5";

  postgisImage = "docker.io/postgis/postgis";
  postgisVersion = "16-3.5";
  postgisDigest = "sha256:94146ac37bc61e2322f88016056c5920729cb8c64c8542ed590af8fc2abdac07";

  subdomain = "travel";
  port = "20080";
  internalPort = "80";

  inherit (self.lib.podman) svc user volume;
in {
  flake.modules = self.factory.container-app {
    name = "adventurelog";

    nixos = {config, ...}: {
      imports = [
        self.modules.nixos.gatus-options
        self.modules.nixos.ingress
        self.modules.nixos.quadlet
        self.modules.nixos.restic
        self.modules.nixos.secrets
      ];

      internal.homelab = {
        backups.adventurelog = {
          databases.postgres = [
            {
              container = "adventurelog-db";
              database = "adventurelog";
              user = "adventurelog";
            }
          ];

          files.paths = map volume ["adventurelog-media"];

          restore.services = {
            afterRestore = map svc ["adventurelog-web"];
            afterSync = map svc ["adventurelog-pod" "adventurelog-db"];
            stop = map svc ["adventurelog-web" "adventurelog-db" "adventurelog-pod"];
          };
        };

        gatus.endpoints.adventurelog = {};

        ingress.adventurelog = {
          inherit port subdomain;
        };
      };

      sops = {
        secrets = {
          "serve/adventurelog/django_admin_password" = {};
          "serve/adventurelog/oidc/client_id" = {};
          "serve/adventurelog/oidc/client_secret" = {};
          "serve/adventurelog/postgres_password" = {};
          "serve/adventurelog/secret_key" = {};
        };

        templates."adventurelog-env" = {
          mode = "0400";
          content = ''
            POSTGRES_DB=adventurelog
            POSTGRES_USER=adventurelog
            POSTGRES_PASSWORD=${config.sops.placeholder."serve/adventurelog/postgres_password"}
            SECRET_KEY=${config.sops.placeholder."serve/adventurelog/secret_key"}
            DJANGO_ADMIN_PASSWORD=${config.sops.placeholder."serve/adventurelog/django_admin_password"}
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

      url = "https://${subdomain}.${osConfig.internal.homelab.domain}";
      envFile = osConfig.sops.templates."adventurelog-env".path;
    in {
      containers = {
        adventurelog-db = {
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
            image = "${postgisImage}:${postgisVersion}@${postgisDigest}";
            noNewPrivileges = true;
            pod = pods.adventurelog.ref;
            pull = "newer";
            volumes = ["adventurelog-db:/var/lib/postgresql/data"];
          };

          serviceConfig.Restart = "always";
          unitConfig.Description = "AdventureLog PostgreSQL/PostGIS Database";
        };

        adventurelog-web = {
          containerConfig = {
            addCapabilities = [
              "CHOWN"
              "DAC_OVERRIDE"
              "FOWNER"
              "NET_BIND_SERVICE"
              "SETGID"
              "SETUID"
            ];

            dropCapabilities = ["ALL"];
            environmentFiles = [envFile];

            environments = {
              CSRF_TRUSTED_ORIGINS = url;
              DISABLE_REGISTRATION = "True";
              DJANGO_ADMIN_USERNAME = "admin";
              FORCE_SOCIALACCOUNT_LOGIN = "True";
              ORIGIN = url;
              PGHOST = "localhost";
              PORT = internalPort;
              SITE_URL = url;
              SOCIALACCOUNT_ALLOW_SIGNUP = "True";
            };

            image = "${appImage}:${appVersion}@${appDigest}";
            noNewPrivileges = true;
            pod = pods.adventurelog.ref;
            pull = "newer";
            volumes = ["adventurelog-media:/code/media"];
          };

          serviceConfig.Restart = "always";

          unitConfig = {
            After = map svc ["adventurelog-db"];
            Description = "AdventureLog Travel Tracker";
            Requires = map svc ["adventurelog-db"];
          };
        };
      };

      pods.adventurelog = {
        autoStart = true;

        podConfig = {
          exitPolicy = "continue";
          publishPorts = ["127.0.0.1:${port}:${internalPort}"];
        };
      };

      volumes = {
        adventurelog-db = {};
        adventurelog-media = {};
      };
    };
  };
}
