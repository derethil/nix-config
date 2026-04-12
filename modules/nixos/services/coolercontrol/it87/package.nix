{
  lib,
  src,
  kernel,
  kernelModuleMakeFlags ? [],
}:
  kernel.stdenv.mkDerivation {
    pname = "it87-${kernel.version}";
    version = "h2ram-mmio";

    inherit src;

    hardeningDisable = ["pic"];

    nativeBuildInputs = kernel.moduleBuildDependencies;

    preConfigure = ''
      sed -i 's|depmod|#depmod|' Makefile
    '';

    makeFlags =
      kernelModuleMakeFlags
      ++ [
        "TARGET=${kernel.modDirVersion}"
        "KERNEL_MODULES=${kernel.dev}/lib/modules/${kernel.modDirVersion}"
        "MODDESTDIR=$(out)/lib/modules/${kernel.modDirVersion}/kernel/drivers/hwmon"
      ];

    meta = with lib; {
      description = "Out-of-tree kernel module for ITE IT87 hardware monitoring with better X870E support";
      homepage = "https://github.com/frankcrawford/it87";
      license = licenses.gpl2Plus;
      platforms = platforms.linux;
      maintainers = [];
    };
  }
