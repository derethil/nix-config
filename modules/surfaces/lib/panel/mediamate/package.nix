{lib, ...}: {
  perSystem = {
    pkgs,
    system,
    ...
  }:
    lib.optionalAttrs (lib.elem system lib.platforms.darwin) {
      packages.mediamate = pkgs.stdenvNoCC.mkDerivation rec {
        build = "319";

        installPhase = ''
          mkdir -p $out/Applications
          cp -r MediaMate.app $out/Applications/
        '';

        nativeBuildInputs = [pkgs.unzip];
        pname = "mediamate";
        sourceRoot = ".";

        src = pkgs.fetchurl {
          hash = "sha256-ZW9xi1ueU+FA/rtPCwJTzyYHXCz2P2r4vybzJDkthBY=";
          url = "https://github.com/Wouter01/MediaMate-Releases/releases/download/v${version}_${build}/MediaMate_v${version}-${build}.zip";
        };

        version = "3.8.3";
        meta.platforms = lib.platforms.darwin;
      };
    };
}
