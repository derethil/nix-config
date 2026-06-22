{lib, ...}: {
  perSystem = {
    system,
    pkgs,
    ...
  }:
    lib.optionalAttrs (lib.elem system lib.platforms.darwin) {
      packages.mediamate = pkgs.stdenvNoCC.mkDerivation rec {
        pname = "mediamate";
        version = "3.8.3";
        build = "319";

        src = pkgs.fetchurl {
          url = "https://github.com/Wouter01/MediaMate-Releases/releases/download/v${version}_${build}/MediaMate_v${version}-${build}.zip";
          hash = "sha256-ZW9xi1ueU+FA/rtPCwJTzyYHXCz2P2r4vybzJDkthBY=";
        };

        nativeBuildInputs = [pkgs.unzip];
        sourceRoot = ".";

        installPhase = ''
          mkdir -p $out/Applications
          cp -r MediaMate.app $out/Applications/
        '';

        meta.platforms = lib.platforms.darwin;
      };
    };
}
