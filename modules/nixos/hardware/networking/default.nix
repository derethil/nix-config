{
  config,
  lib,
  host,
  ...
}: let
  inherit (lib) mkIf mkMerge types mkForce;
  inherit (lib.glace) mkBoolOpt mkOpt;
  cfg = config.glace.hardware.networking;
in {
  options.glace.hardware.networking = with types; {
    enable = mkBoolOpt false "Whether or not to enable networking support";
    hosts = mkOpt attrs {} "An attribute set to merge with <option>networking.hosts</option>";
    avahi.enable = mkBoolOpt false "Whether or not to enable Avahi host resolution on local networks.";
  };

  config = mkIf cfg.enable {
    networking = {
      hosts = mkMerge [
        {"127.0.0.1" = ["test.local"];}
        cfg.hosts
      ];

      networkmanager = {
        enable = true;
        dhcp = "internal";
      };

      hostName = host;
    };

    # we don't want to wait for network on boot, takes ~5s extra
    systemd.services.NetworkManager-wait-online.enable = mkForce false;

    glace.user.extraGroups = ["networkmanager"];

    glace.system.impermanence.extraDirectories = [
      "/etc/NetworkManager/system-connections"
    ];

    services.avahi = mkIf cfg.avahi.enable {
      enable = true;
      nssmdns4 = true;
      nssmdns6 = true;
      publish = {
        enable = true;
        addresses = true;
        domain = true;
        workstation = true;
      };
    };
  };
}
