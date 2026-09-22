{self, ...}: {
  flake.modules.nixos.prowlarr = {config, ...}: let
    version = "2.6.5";

    subdomain = "index";
    port = "20070";
    internalPort = "9696";

    puid = "1000";
    pgid = "1000";

    inherit (config.virtualisation.quadlet) pods;
    inherit (self.lib.podman) svc volume;
  in {
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

    virtualisation.quadlet = {
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

          image = "lscr.io/linuxserver/prowlarr:${version}";
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
