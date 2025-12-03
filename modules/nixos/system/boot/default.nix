{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf types;
  inherit (lib.glace) mkBoolOpt mkOpt;
  cfg = config.glace.system.boot;
in {
  options.glace.system.boot = {
    enable = mkBoolOpt false "Whether to enable systemd-boot configuration.";
    kernelPackages = mkOpt types.raw pkgs.unstable.linuxPackages_latest "Kernel packages to use.";
    plymouth.enable = mkBoolOpt false "Whether to enable Plymouth splash screens.";
    kernelParams = {
      fix-xhci-controllers.enable = mkBoolOpt false "Whether to add kernel parameters to fix Intel xHCI USB controller issues on some hardware.";
    };
  };

  config = mkIf cfg.enable {
    boot = {
      bootspec.enable = true;
      loader = {
        efi.canTouchEfiVariables = true;
        systemd-boot = {
          enable = true;
          configurationLimit = 5;
        };
      };

      plymouth = {
        enable = cfg.plymouth.enable;
      };

      kernelPackages = cfg.kernelPackages;

      kernelParams = lib.optionals cfg.kernelParams.fix-xhci-controllers.enable [
        "xhci_hcd.quirks=64"
      ];
    };
  };
}
