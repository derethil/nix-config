{
  lib,
  fetchFromGitHub,
  kernel,
  kernelModuleMakeFlags ? [],
}: let
  version = "unstable-2026-03-16";
  sha256 = "7tZtod7uWIDsJIL74v9qlBRtmEri17AmGgf+zUHmHf4=";
in
  kernel.stdenv.mkDerivation rec {
    pname = "it87-${version}-${kernel.version}";
    inherit version;

    src = fetchFromGitHub {
      owner = "frankcrawford";
      repo = "it87";
      rev = "h2ram-mmio";
      inherit sha256;
    };

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
