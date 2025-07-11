{
  config,
  lib,
  ...
}:
with lib;
with lib.internal; let
  cfg = config.hardware.brillo;
in {
  options.hardware.brillo = with types; {
    enable = mkBoolOpt false "Whether or not to enable Brillo backlight control.";
  };

  config = mkIf cfg.enable {
    hardware.brillo.enable = true;
  };
}
