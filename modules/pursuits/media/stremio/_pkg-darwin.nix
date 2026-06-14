{
  stdenvNoCC,
  fetchurl,
  undmg,
  darwin,
  cctools,
}:
stdenvNoCC.mkDerivation rec {
  pname = "stremio";
  version = "5.1.22";

  src = fetchurl {
    url = "https://dl.strem.io/stremio-shell-macos/v${version}/Stremio_arm64.dmg";
    hash = "sha256-Xn+BKvSQJFWlx4Cy6gjvA4e9qViJ+x86F3yhK+GiFuY=";
  };

  nativeBuildInputs = [undmg darwin.sigtool cctools];

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
