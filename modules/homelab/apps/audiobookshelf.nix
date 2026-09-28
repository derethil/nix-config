{self, ...}: {
  flake.modules.nixos.audiobookshelf = {config, ...}: let
    version = "2.36.1";

    subdomain = "audio";
    port = "20100";
    internalPort = "80";

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
      backups.audiobookshelf = {
        databases.sqlite = [
          {
            name = "audiobookshelf";
            path = "${volume "audiobookshelf-config"}/absdatabase.sqlite";
          }
        ];

        files = {
          exclude = map (f: "${volume "audiobookshelf-config"}/${f}") [
            "absdatabase.sqlite"
            "absdatabase.sqlite-shm"
            "absdatabase.sqlite-wal"
          ];

          paths = map volume ["audiobookshelf-config" "audiobookshelf-metadata"];
        };

        restore.services = {
          afterRestore = map svc ["audiobookshelf-web"];
          afterSync = map svc ["audiobookshelf-pod"];
          stop = map svc ["audiobookshelf-web" "audiobookshelf-pod"];
        };
      };

      gatus.endpoints.audiobookshelf = {};

      ingress.audiobookshelf = {
        inherit port subdomain;
      };
    };

    virtualisation.quadlet = {
      containers.audiobookshelf-web = {
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
          image = "ghcr.io/advplyr/audiobookshelf:${version}";
          noNewPrivileges = true;
          pod = pods.audiobookshelf.ref;
          pull = "newer";

          volumes = [
            "audiobookshelf-audiobooks:/audiobooks"
            "audiobookshelf-podcasts:/podcasts"
            "audiobookshelf-config:/config"
            "audiobookshelf-metadata:/metadata"
          ];
        };

        serviceConfig.Restart = "always";
        unitConfig.Description = "Audiobookshelf Audiobook & Podcast Server";
      };

      pods.audiobookshelf = {
        autoStart = true;

        podConfig = {
          exitPolicy = "continue";
          publishPorts = ["127.0.0.1:${port}:${internalPort}"];
        };
      };

      volumes = {
        audiobookshelf-audiobooks = {};
        audiobookshelf-config = {};
        audiobookshelf-metadata = {};
        audiobookshelf-podcasts = {};
      };
    };
  };
}
