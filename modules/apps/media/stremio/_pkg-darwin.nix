{
  cctools,
  darwin,
  fetchurl,
  stdenvNoCC,
  undmg,
}: let
  release = {
    datasource = "custom.stremio";
    packageName = "stremio";
    version = "5.1.26";
    versioning = "semver";
  };
in
  stdenvNoCC.mkDerivation {
    inherit (release) version;

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
      # regen-hash-url: packages.aarch64-darwin.stremio.src.url
      hash = "sha256-Xn+BKvSQJFWlx4Cy6gjvA4e9qViJ+x86F3yhK+GiFuY=";
      url = "https://dl.strem.io/stremio-shell-macos/v${release.version}/Stremio_arm64.dmg";
    };

    meta.platforms = ["aarch64-darwin"];
  }
