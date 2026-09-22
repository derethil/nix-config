{
  cctools,
  darwin,
  fetchurl,
  stdenvNoCC,
  undmg,
}:
stdenvNoCC.mkDerivation rec {
  installPhase = ''
    mkdir -p $out/Applications
    cp -r Stremio.app $out/Applications/

    app=$out/Applications/Stremio.app/Contents/MacOS
    for f in $app/*.dylib $app/ffmpeg $app/ffprobe $app/node $app/Stremio; do
      codesign -f -s - "$f"
    done
  '';

  nativeBuildInputs = [cctools darwin.sigtool undmg];
  pname = "stremio";
  sourceRoot = ".";

  src = fetchurl {
    hash = "sha256-Xn+BKvSQJFWlx4Cy6gjvA4e9qViJ+x86F3yhK+GiFuY=";
    url = "https://dl.strem.io/stremio-shell-macos/v${version}/Stremio_arm64.dmg";
  };

  version = "5.1.22";
  meta.platforms = ["aarch64-darwin"];
}
