{
  lib,
  stdenv,
  fetchurl,
  appimageTools,
  undmg,
  ...
}:
let
  pname = "iloader";
  version = "1.1.6";

  sources = {
    x86_64-linux = {
      url = "https://github.com/nab138/iloader/releases/download/v${version}/iloader-linux-amd64.AppImage";
      hash = "sha256-L1fFwFjdIrrhviBlwORhSDXsNYgrT1NcVKAKlss6h4o=";
    };
    x86_64-darwin = {
      url = "https://github.com/nab138/iloader/releases/download/v${version}/iloader-darwin-universal.app.tar.gz";
      hash = "sha256-OQa5cQx2KIh1op3wMH0I8v9vXOq6PeF00Z0NQRL823s=";
    };
    aarch64-darwin = {
      url = "https://github.com/nab138/iloader/releases/download/v${version}/iloader-darwin-universal.app.tar.gz";
      hash = "sha256-OQa5cQx2KIh1op3wMH0I8v9vXOq6PeF00Z0NQRL823s=";
    };
  };

  src = fetchurl (sources.${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}"));

  meta = with lib; {
    description = "A user-friendly desktop application for sideloading apps onto iOS devices";
    homepage = "https://github.com/nab138/iloader";
    license = licenses.mit;
    platforms = ["x86_64-linux" "x86_64-darwin" "aarch64-darwin"];
    maintainers = [];
  };
in
if stdenv.isLinux then
  let
    appimageContents = appimageTools.extractType2 {inherit pname version src;};
  in
    appimageTools.wrapType2 {
      inherit pname version src meta;

      extraInstallCommands = ''
        install -Dm444 ${appimageContents}/iloader.desktop -t $out/share/applications
        install -Dm444 ${appimageContents}/iloader.png -t $out/share/pixmaps
      '';
    }
else
  stdenv.mkDerivation {
    inherit pname version src meta;

    sourceRoot = ".";

    installPhase = ''
      runHook preInstall
      mkdir -p $out/Applications
      cp -r iloader.app $out/Applications/
      runHook postInstall
    '';
  }
