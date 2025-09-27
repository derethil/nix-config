{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf types;
  inherit (lib.internal) mkBoolOpt mkOpt;
  cfg = config.system.boot;
in {
  options.system.boot = {
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
    system.nixos.label = lib.mkForce (let
      formattedDate = lib.strings.removeSuffix "\n" (builtins.readFile (pkgs.runCommand "current-date" {} ''
        date "+%m-%d-%y_%I:%M%p" > $out
      ''));
    in "${config.system.nixos.version}_Generation_${toString config.system.nixos.revision or "unknown"}_${formattedDate}");
  };
}
