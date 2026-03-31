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
    plymouth.enable = mkBoolOpt false "Whether to enable Plymouth splash screens.";
    kernel = {
      cachyos.enable = mkBoolOpt false "Whether to enable the CachyOS kernel.";
      packages = mkOpt types.raw pkgs.unstable.linuxPackages_latest "Kernel packages to use.";
      params = mkOpt (types.listOf types.str) [] "Kernel parameters to add.";
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

      kernelPackages =
        if cfg.kernel.cachyos.enable
        then pkgs.cachyosKernels.linuxPackages-cachyos-latest
        else cfg.kernel.packages;

      kernelParams = cfg.kernel.params;
    };
  };
}
