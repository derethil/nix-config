{
  pkgs,
  lib,
  ...
}: let
  inherit (lib) getExe;

  name = "melonloader-installer";
  version = "4.2.0";

  icon = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/LavaGang/MelonLoader.Installer/${unwrapped.version}/Resources/ML_Icon.png";
    sha256 = "sha256-wxXRKKm6G6NA38ET5jDwn+CePhVqiuOqhs7zT6PXaMc=";
  };

  unwrapped = pkgs.buildDotnetModule rec {
    inherit version;
    pname = "${name}-unwrapped";

    src = pkgs.fetchFromGitHub {
      owner = "LavaGang";
      repo = "MelonLoader.Installer";
      rev = version;
      sha256 = "sha256-bvfOjN+EIdEMlS0noB5Jwosv4Z31MhyNpFydkzN6nDQ=";
    };

    projectFile = "MelonLoader.Installer/MelonLoader.Installer.csproj";
    dotnet-sdk = pkgs.dotnetCorePackages.sdk_9_0;
    dotnet-runtime = pkgs.dotnetCorePackages.runtime_9_0;
    nugetDeps = ./deps.json;

    patches = [./disable-updater.patch];

    dotnetInstallFlags = ["-p:PublishSingleFile=false"];
  };

  wrapped = pkgs.buildFHSEnv {
    inherit name;
    targetPkgs = pkgs: [unwrapped];
    runScript = "${unwrapped}/bin/MelonLoader.Installer.Linux";
  };
in
  pkgs.stdenv.mkDerivation {
    inherit name version;

    dontUnpack = true;

    desktopItem = pkgs.makeDesktopItem {
      inherit icon name;
      desktopName = "MelonLoader Installer";
      comment = "Mod Loader for Unity Games compatible with both Il2Cpp and Mono";
      exec = getExe wrapped;
      categories = ["Game" "Utility"];
      keywords = ["mod" "modding" "unity"];
    };

    buildCommand = ''
      mkdir -p $out/bin
      ln -s ${getExe wrapped} $out/bin/${name}
      install -m 644 -D -t $out/share/applications $desktopItem/share/applications/*
    '';

    meta = {
      platforms = lib.platforms.linux;
    };
  }
