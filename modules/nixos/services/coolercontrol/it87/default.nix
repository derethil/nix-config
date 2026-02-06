{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.services.coolercontrol.it87;

  it87-module = pkgs.callPackage ./package.nix {
    kernel = config.boot.kernelPackages.kernel;
  };
in {
  options.glace.services.coolercontrol.it87 = {
    enable = mkBoolOpt false "Enable it87 hardware monitoring driver for Super I/O chip (needed for some Gigabyte motherboards like X870E).";
    ignoreResourceConflict = mkBoolOpt true "Set ignore_resource_conflict=1 for it87 module.";
    mmio = mkBoolOpt false "Use MMIO to access the chip (required for X870E boards). Uses out-of-tree driver from frankcrawford/it87.";
  };

  config = mkIf cfg.enable {
    boot.kernelModules = ["it87"];

    boot.extraModprobeConfig = let
      options = lib.flatten [
        (lib.optional cfg.ignoreResourceConflict "ignore_resource_conflict=1")
        (lib.optional cfg.mmio "mmio=on")
      ];
    in ''
      options it87 ${lib.concatStringsSep " " options}
    '';

    # Use out-of-tree it87 driver when MMIO is enabled (for X870E support)
    # PR: https://github.com/frankcrawford/it87/pull/77
    boot.extraModulePackages = mkIf cfg.mmio [
      it87-module
    ];
  };
}
