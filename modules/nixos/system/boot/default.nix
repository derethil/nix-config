{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf types flatten;
  inherit (lib.glace) mkBoolOpt mkOpt;
  cfg = config.glace.system.boot;
in {
  options.glace.system.boot = {
    enable = mkBoolOpt false "Whether to enable systemd-boot configuration.";
    kernelPackages = mkOpt types.raw pkgs.unstable.linuxPackages_latest "Kernel packages to use.";
    plymouth.enable = mkBoolOpt false "Whether to enable Plymouth splash screens.";
    kernelParams = {
      fix-xhci-controllers.enable = mkBoolOpt false "Whether to add kernel parameters to fix Intel xHCI USB controller issues on some hardware.";
      disable-pcie-aspm.enable = mkBoolOpt false "Whether to disable PCIe ASPM.";
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

      kernelParams = flatten [
        (lib.optionals cfg.kernelParams.fix-xhci-controllers.enable [
          "xhci_hcd.quirks=64"
        ])
        (lib.optionals cfg.kernelParams.disable-pcie-aspm.enable [
          "pcie_aspm=off"
        ])
      ];
    };
  };
}
