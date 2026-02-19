{
  pkgs,
  stdenvNoCC,
  fetchurl,
  undmg,
  cctools,
  ...
}:
stdenvNoCC.mkDerivation rec {
  pname = "stremio";
  version = "5.1.14";

  src = fetchurl {
    url = "https://dl.strem.io/stremio-shell-macos/v${version}/Stremio_arm64.dmg";
    hash = "sha256-fnyaekM7fTuUkezeEK/mTKCRKj5cORJvDQTabxRIS9k=";
  };

  nativeBuildInputs = [undmg pkgs.darwin.sigtool cctools];

  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out/Applications
    cp -r Stremio.app $out/Applications/

    app=$out/Applications/Stremio.app/Contents/MacOS
    for f in $app/*.dylib $app/ffmpeg $app/ffprobe $app/node $app/Stremio; do
      codesign -f -s - "$f"
    done
  '';

  meta.platforms = ["aarch64-darwin"];
}
