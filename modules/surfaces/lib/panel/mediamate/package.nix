{lib, ...}: {
  perSystem = {
    pkgs,
    system,
    ...
  }: let
    version = "3.8.4";
    build = "321";
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
