{self, ...}: let
  appImage = "lscr.io/linuxserver/prowlarr";
  appVersion = "2.7.0";
  appDigest = "sha256:6660787a99b2e58203539583663c973b48979fc00ff2cb78dc0ea17429e1f6ef";

  subdomain = "index";
  port = "20070";
  internalPort = "9696";

  puid = "1000";
  pgid = "1000";

  inherit (self.lib.podman) svc volume;
in {
  flake.modules = self.factory.container-app {
    name = "prowlarr";

    nixos = {
      imports = [
        self.modules.nixos.gatus-options
        self.modules.nixos.ingress
        self.modules.nixos.quadlet
        self.modules.nixos.restic
      ];

      internal.homelab = {
        backups.prowlarr = {
          databases.sqlite = [
            {
              name = "prowlarr";
              path = "${volume "prowlarr-config"}/prowlarr.db";
            }
            {
              name = "prowlarr-logs";
              path = "${volume "prowlarr-config"}/logs.db";
            }
          ];

          files = {
            exclude = map (f: "${volume "prowlarr-config"}/${f}") [
              "prowlarr.db"
              "prowlarr.db-shm"
              "prowlarr.db-wal"
              "logs.db"
              "logs.db-shm"
              "logs.db-wal"
            ];

            paths = map volume ["prowlarr-config"];
          };

          restore.services = {
            afterRestore = map svc ["prowlarr-web"];
            afterSync = map svc ["prowlarr-pod"];
            stop = map svc ["prowlarr-web" "prowlarr-pod"];
          };
        };

        gatus.endpoints.prowlarr = {};

        ingress.prowlarr = {
          inherit port subdomain;
          caddy.forwardAuth.enable = true;
        };
      };
    };

    quadlet = {config, ...}: let
      inherit (config.virtualisation.quadlet) pods;
    in {
      containers.prowlarr-web = {
        containerConfig = {
          addCapabilities = [
            "CHOWN"
            "DAC_OVERRIDE"
            "FOWNER"
            "SETGID"
            "SETUID"
          ];

          dropCapabilities = ["ALL"];

          environments = {
            PGID = pgid;
            PUID = puid;
          };

          image = "${appImage}:${appVersion}@${appDigest}";
          noNewPrivileges = true;
          pod = pods.prowlarr.ref;
          pull = "newer";
          volumes = ["prowlarr-config:/config"];
        };

        serviceConfig.Restart = "always";
        unitConfig.Description = "Prowlarr Indexer Manager";
      };

      pods.prowlarr = {
        autoStart = true;

        podConfig = {
          exitPolicy = "continue";
          publishPorts = ["127.0.0.1:${port}:${internalPort}"];
        };
      };

      volumes.prowlarr-config = {};
    };
  };
}
