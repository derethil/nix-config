{lib, ...}: {
  perSystem = {
    pkgs,
    system,
    ...
  }: let
    release = {
      datasource = "github-releases";
      extractVersion = "^v(?<version>.+)$";
      packageName = "Wouter01/MediaMate-Releases";
      version = "3.8.4_321";
      versioning = "regex:^(?<major>[0-9]+)[.](?<minor>[0-9]+)[.](?<patch>[0-9]+)_(?<build>[0-9]+)$";
    };

    releaseParts = lib.splitString "_" release.version;
    version = builtins.elemAt releaseParts 0;
    build = builtins.elemAt releaseParts 1;
  in
    lib.optionalAttrs (lib.elem system lib.platforms.darwin) {
      packages.mediamate = pkgs.stdenvNoCC.mkDerivation {
        inherit build version;

        installPhase = ''
          mkdir -p $out/Applications
          cp -r MediaMate.app $out/Applications/
        '';

        nativeBuildInputs = [pkgs.unzip];
        pname = "mediamate";
        sourceRoot = ".";

        src = pkgs.fetchurl {
          hash = "sha256-Rhq+5HODz/qhSppNXhzO5AnZcwbzAN1NxwXD12got04=";
          url = "https://github.com/Wouter01/MediaMate-Releases/releases/download/v${version}_${build}/MediaMate_v${version}-${build}.zip";
        };

        meta.platforms = lib.platforms.darwin;
      };
    };
}
