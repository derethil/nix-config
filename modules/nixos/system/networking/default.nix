{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkMerge types;
  inherit (lib.internal) mkBoolOpt mkOpt;
  cfg = config.hardware.networking;
in {
  options.hardware.networking = with types; {
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
    };

    user.extraGroups = ["networkmanager"];

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
