{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.services.openrgb;
in {
  options.glace.services.openrgb = {
    enable = mkBoolOpt false "Whether to enable OpenRGB service.";
  };

  config = mkIf cfg.enable {
    services.hardware.openrgb = {
      enable = true;
      package = pkgs.unstable.openrgb-with-all-plugins;
    };

    # Enable i2c devices for RAM detection
    boot.kernelModules = ["i2c-dev"];
    boot.kernelParams = ["acpi_enforce_resources=lax"];
  };
}
