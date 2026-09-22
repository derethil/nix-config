{self, ...}: {
  flake.modules.nixos.sabnzbd = {config, ...}: let
    version = "5.1.3";

    subdomain = "index.sabnzbd";
    port = "20090";
    internalPort = "8080";

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

    virtualisation.quadlet = {
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

          image = "lscr.io/linuxserver/sabnzbd:${version}";
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
