{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.services.usbmuxd;
in {
  options.glace.services.usbmuxd = {
    enable = mkBoolOpt false "Whether to enable usbmuxd.";
  };

  config = mkIf cfg.enable {
    services.usbmuxd = {
      enable = true;
      package = pkgs.usbmuxd2;
    };

    environment.systemPackages = [
      pkgs.libimobiledevice
    ];
  };
}
