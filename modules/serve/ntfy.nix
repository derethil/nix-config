{
  self,
  lib,
  ...
}: {
  flake.modules.nixos.ntfy = {
    config,
    pkgs,
    ...
  }: let
    version = "2.26.3";
    subdomain = "notify";
    port = "20040";
    internalPort = "8080";
    host = "${subdomain}.${config.internal.homelab.domain}";

    configFile = lib.generators.toYAML {} {
      default-host = "https://${host}";
    };
  in {
    imports = [
      self.modules.nixos.homelab-routing
      self.modules.nixos.quadlet
    ];

    environment = {
      etc."ntfy/client.yml".text = configFile;
      systemPackages = [pkgs.ntfy-sh];
    };

    home-manager.sharedModules = [
      {xdg.configFile."ntfy/client.yml".text = configFile;}
    ];

    internal.homelab.routing.ntfy = {
      inherit port subdomain;
    };

    virtualisation.quadlet = {
      containers.ntfy = {
        containerConfig = {
          dropCapabilities = ["ALL"];

          environments = {
            NTFY_BASE_URL = "https://${host}";
            NTFY_BEHIND_PROXY = "true";
            NTFY_CACHE_DURATION = "12h";
            NTFY_CACHE_FILE = "/var/lib/ntfy/cache.db";
            NTFY_LISTEN_HTTP = ":${internalPort}";
            # forward poll requests upstream so iOS gets instant push via APNS
            NTFY_UPSTREAM_BASE_URL = "https://ntfy.sh";
          };

          exec = ["serve"];
          image = "docker.io/binwiederhier/ntfy:v${version}";
          noNewPrivileges = true;
          publishPorts = ["127.0.0.1:${port}:${internalPort}"];
          pull = "newer";
          volumes = ["ntfy-cache:/var/lib/ntfy"];
        };

        serviceConfig.Restart = "always";
        unitConfig.Description = "ntfy Push Notifications";
      };

      volumes.ntfy-cache = {};
    };
  };
}
