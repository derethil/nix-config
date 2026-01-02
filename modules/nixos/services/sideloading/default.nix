{
  lib,
  config,
  pkgs,
  namespace,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.services.sideloading;
in {
  options.glace.services.sideloading = {
    enable = mkBoolOpt false "Whether to enable iOS sideloading tools.";
  };

  config = mkIf cfg.enable {
    services.usbmuxd = {
      enable = true;
      package = pkgs.usbmuxd2;
    };

    environment.systemPackages = [
      pkgs.libimobiledevice
      pkgs.${namespace}.iloader
    ];
  };
}
