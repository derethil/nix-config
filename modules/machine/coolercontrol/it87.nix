{
  self,
  lib,
  inputs,
  ...
}: {
  flake-file.inputs.it87 = {
    flake = false;
    url = "github:frankcrawford/it87/h2ram-mmio";
  };

  flake.modules.nixos.coolercontrol-it87 = {config, ...}: let
    inherit (lib) concatStringsSep flatten mkIf mkOption optional types;
    cfg = config.internal.services.coolercontrol.it87;
    kernel = config.boot.kernelPackages.kernel;

    # X870E and similar boards need an out-of-tree it87 driver for MMIO.
    # See https://github.com/frankcrawford/it87/pull/77
    it87-module = kernel.stdenv.mkDerivation {
      hardeningDisable = ["pic"];

      makeFlags = [
        "KERNEL_MODULES=${kernel.dev}/lib/modules/${kernel.modDirVersion}"
        "MODDESTDIR=$(out)/lib/modules/${kernel.modDirVersion}/kernel/drivers/hwmon"
        "TARGET=${kernel.modDirVersion}"
      ];

      nativeBuildInputs = kernel.moduleBuildDependencies;
      pname = "it87-${kernel.version}";

      preConfigure = ''
        sed -i 's|depmod|#depmod|' Makefile
      '';

      src = inputs.it87;
      version = "h2ram-mmio";

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
      ignoreResourceConflict = mkOption {
        default = true;
        description = "Set ignore_resource_conflict=1 for the it87 module.";
        type = types.bool;
      };

      mmio = mkOption {
        default = false;
        description = "Use MMIO to access the chip (required for X870E boards). Pulls the out-of-tree driver.";
        type = types.bool;
      };
    };

    config.boot = let
      options = flatten [
        (optional cfg.ignoreResourceConflict "ignore_resource_conflict=1")
        (optional cfg.mmio "mmio=on")
      ];
    in {
      extraModprobeConfig = ''
        options it87 ${concatStringsSep " " options}
      '';

      extraModulePackages = mkIf cfg.mmio [it87-module];
      kernelModules = ["it87"];
    };
  };
}
