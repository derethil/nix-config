{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.hardware.power-management;
in {
  options.glace.hardware.power-management = {
    enable = mkBoolOpt false "power management optimizations";
  };

  config = mkIf cfg.enable {
    # Fix Intel xHCI USB controller suspend/resume issues
    boot.kernelParams = [
      "xhci_hcd.quirks=64"
    ];
  };
}