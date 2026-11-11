{self, ...}: let
  appImage = "lscr.io/linuxserver/sabnzbd";
  appVersion = "5.1.3";
  appDigest = "sha256:693c208f697d0b411410edd92a98b52c8c754c01f5c078a975cbc892044260f5";

  subdomain = "index.sabnzbd";
  port = "20090";
  internalPort = "8080";

  puid = "1000";
  pgid = "1000";

  inherit (self.lib.podman) svc volume;
in {
  flake.modules = self.factory.container-app {
    name = "sabnzbd";

    nixos = {
      imports = [
        self.modules.nixos.gatus-options
        self.modules.nixos.ingress
        self.modules.nixos.quadlet
        self.modules.nixos.restic
      ];

      internal.homelab = {
        backups.sabnzbd = {
          files.paths = map volume ["sabnzbd-config"];

          restore.services = {
            afterRestore = map svc ["sabnzbd-web"];
            afterSync = map svc ["sabnzbd-pod"];
            stop = map svc ["sabnzbd-web" "sabnzbd-pod"];
          };
        };

        gatus.endpoints.sabnzbd = {};

        ingress.sabnzbd = {
          inherit port subdomain;
          caddy.forwardAuth.enable = true;
        };
      };
    };

    quadlet = {config, ...}: let
      inherit (config.virtualisation.quadlet) pods;
    in {
      containers.sabnzbd-web = {
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
          pod = pods.sabnzbd.ref;
          pull = "newer";

          volumes = [
            "sabnzbd-config:/config"
            "sabnzbd-downloads:/downloads"
            "sabnzbd-incomplete:/incomplete-downloads"
          ];
        };

        serviceConfig.Restart = "always";
        unitConfig.Description = "SABnzbd Usenet Downloader";
      };

      pods.sabnzbd = {
        autoStart = true;

        podConfig = {
          exitPolicy = "continue";
          publishPorts = ["127.0.0.1:${port}:${internalPort}"];
        };
      };

      volumes = {
        sabnzbd-config = {};
        sabnzbd-downloads = {};
        sabnzbd-incomplete = {};
      };
    };
  };
}
