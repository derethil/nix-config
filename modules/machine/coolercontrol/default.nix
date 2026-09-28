{lib, ...}: {
  flake.modules.nixos.coolercontrol = {
    config,
    pkgs,
    ...
  }: let
    inherit (lib) mkEnableOption mkIf mkMerge;

    webCfg = config.internal.services.coolercontrol.web;
    port = 11987;
  in {
    options.internal.services.coolercontrol.web.enable = mkEnableOption "private-network access and homelab ingress for the CoolerControl web UI";

    config = mkMerge [
      {
        environment.systemPackages = [pkgs.lm_sensors];

        internal.boot.impermanence.extraDirectories = [
          "/etc/coolercontrol"
        ];

        programs.coolercontrol.enable = true;
      }

      (mkIf webCfg.enable {
        internal.homelab.ingress.coolercontrol = {
          inherit port;
          caddy.forwardAuth.enable = true;
          subdomain = "cooling.${config.networking.hostName}";
        };

        networking.firewall.interfaces."tailscale0".allowedTCPPorts = [port];

        systemd.services.coolercontrold.environment = {
          CC_HOST_IP4 = "0.0.0.0";
          CC_HOST_IP6 = "::";
          CC_PORT = toString port;
          CC_TLS = "OFF";
        };
      })
    ];
  };
}
