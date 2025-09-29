{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.hardware.bluetooth;
in {
  options.glace.hardware.bluetooth = {
    enable = mkBoolOpt false "Whether to enable Bluetooth support on this system.";
  };

  config = mkIf cfg.enable {
    hardware.bluetooth.enable = true;
    hardware.bluetooth.powerOnBoot = true;
    environment.systemPackages = [pkgs.bluetuith];
  };
}

