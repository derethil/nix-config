{
  inputs,
  self,
  lib,
  ...
}: {
  flake-file.inputs.it87 = {
    url = "github:frankcrawford/it87/h2ram-mmio";
    flake = false;
  };

  flake.modules.nixos.coolercontrol-it87 = {config, ...}: let
    inherit (lib) mkOption mkIf optional flatten concatStringsSep types;
    cfg = config.internal.services.coolercontrol.it87;
    kernel = config.boot.kernelPackages.kernel;

    # X870E and similar boards need an out-of-tree it87 driver for MMIO.
    # See https://github.com/frankcrawford/it87/pull/77
    it87-module = kernel.stdenv.mkDerivation {
      pname = "it87-${kernel.version}";
      version = "h2ram-mmio";
      src = inputs.it87;

      hardeningDisable = ["pic"];
      nativeBuildInputs = kernel.moduleBuildDependencies;

      preConfigure = ''
        sed -i 's|depmod|#depmod|' Makefile
      '';

      makeFlags = [
        "TARGET=${kernel.modDirVersion}"
        "KERNEL_MODULES=${kernel.dev}/lib/modules/${kernel.modDirVersion}"
        "MODDESTDIR=$(out)/lib/modules/${kernel.modDirVersion}/kernel/drivers/hwmon"
      ];

      meta = {
        description = "Out-of-tree kernel module for ITE IT87 hardware monitoring with better X870E support";
        homepage = "https://github.com/frankcrawford/it87";
        license = lib.licenses.gpl2Plus;
        platforms = lib.platforms.linux;
      };
    };
  in {
    imports = [self.modules.nixos.coolercontrol];

    options.internal.services.coolercontrol.it87 = {
      mmio = mkOption {
        type = types.bool;
        default = false;
        description = "Use MMIO to access the chip (required for X870E boards). Pulls the out-of-tree driver.";
      };
      ignoreResourceConflict = mkOption {
        type = types.bool;
        default = true;
        description = "Set ignore_resource_conflict=1 for the it87 module.";
      };
    };

    config.boot = let
      options = flatten [
        (optional cfg.ignoreResourceConflict "ignore_resource_conflict=1")
        (optional cfg.mmio "mmio=on")
      ];
    in {
      kernelModules = ["it87"];

      extraModprobeConfig = ''
        options it87 ${concatStringsSep " " options}
      '';

      extraModulePackages = mkIf cfg.mmio [it87-module];
    };
  };
}
