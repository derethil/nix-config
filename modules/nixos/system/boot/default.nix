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
    kernelPackages = mkOpt types.raw pkgs.linuxPackages_latest "Kernel packages to use.";
    plymouth.enable = mkBoolOpt false "Whether to enable Plymouth splash screens.";
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
      kernelPackages = cfg.kernelPackages;
      plymouth = {
        enable = cfg.plymouth.enable;
      };
    };
  };
}
