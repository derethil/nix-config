{
  lib,
  fetchFromGitHub,
  kernel,
  kernelModuleMakeFlags ? [],
  llvmPackages,
}: let
  version = "unstable-2025-12-04";
  sha256 = "1kv7gf52ci4s6rfa9cn8s9bmxjyibv95znmy3zwf4zg42jshxrfd";
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

    nativeBuildInputs = with llvmPackages;
      kernel.moduleBuildDependencies
      ++ [
        bintools-unwrapped
        clang-unwrapped
        lld
      ];

    preConfigure = ''
      sed -i 's|depmod|#depmod|' Makefile
    '';

    makeFlags =
      kernelModuleMakeFlags
      ++ [
        "TARGET=${kernel.modDirVersion}"
        "KERNEL_MODULES=${kernel.dev}/lib/modules/${kernel.modDirVersion}"
        "MODDESTDIR=$(out)/lib/modules/${kernel.modDirVersion}/kernel/drivers/hwmon"
        "LLVM=1"
        "LLVM_IAS=1"
      ];

    meta = with lib; {
      description = "Out-of-tree kernel module for ITE IT87 hardware monitoring with better X870E support";
      homepage = "https://github.com/frankcrawford/it87";
      license = licenses.gpl2Plus;
      platforms = platforms.linux;
      maintainers = [];
    };
  }
