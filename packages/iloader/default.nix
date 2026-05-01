{
  lib,
  pkgs,
  stdenv,
  fetchurl,
  appimageTools,
  ...
}: let
  pname = "iloader";
  version = "2.2.5";

  sources = rec {
    x86_64-linux = {
      url = "https://github.com/nab138/iloader/releases/download/v${version}/iloader-linux-amd64.AppImage";
      hash = "sha256-19PzDGn/Sq10xzY1HDwyo02yFrfGRD+0w56OWL1vArg=";
    };

    aarch64-linux = {
      url = "https://github.com/nab138/iloader/releases/download/v${version}/iloader-linux-aarch64.AppImage";
      hash = "sha256-4xQ/h/C2dK8FpCrnMeAkl7uc46xeNISJ2Ked5gFWUqI=";
    };

    x86_64-darwin = {
      url = "https://github.com/nab138/iloader/releases/download/v${version}/iloader-darwin-universal.app.tar.gz";
      hash = "sha256-MCtNJwjMnFYt1Qazp0Ir7Bejsjneo/6LsTd2IFzsoqI=";
    };

    aarch64-darwin = x86_64-darwin;
  };

  src = fetchurl (sources.${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}"));

  meta = with lib; {
    description = "A user-friendly desktop application for sideloading apps onto iOS devices";
    homepage = "https://github.com/nab138/iloader";
    license = licenses.mit;
    platforms = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    maintainers = [];
  };
in
  if stdenv.isLinux
  then let
    # Extract the AppImage and remove bundled Wayland libraries that conflict with system libraries.
    # The AppImage bundles incompatible Wayland libraries that cause EGL_BAD_PARAMETER errors.
    # By removing them, the application will use system Wayland libraries instead.
    # See: https://github.com/nab138/iloader/issues/77
    extracted = appimageTools.extract {
      inherit pname version src;
      postExtract = ''
        chmod -R +w $out
        rm -f $out/usr/lib/*wayland*so*
        rm -f $out/usr/lib/im-wayland*.so
      '';
    };

    fhsEnv = pkgs.buildFHSEnv {
      name = "${pname}-fhs";
      # Include default AppImage dependencies plus system Wayland libraries
      targetPkgs = pkgs:
        (appimageTools.defaultFhsEnvArgs.targetPkgs pkgs)
        ++ (with pkgs; [
          wayland
          libxkbcommon
        ]);
      multiPkgs = appimageTools.defaultFhsEnvArgs.multiPkgs;
      runScript = "${extracted}/AppRun";
    };
  in
    stdenv.mkDerivation {
      inherit pname version meta;

      dontUnpack = true;

      installPhase = ''
        mkdir -p $out/bin $out/share/applications $out/share/pixmaps

        cat > $out/bin/${pname} << EOF
        #!/bin/sh
        exec ${fhsEnv}/bin/${pname}-fhs "\$@"
        EOF
        chmod +x $out/bin/${pname}

        install -Dm444 ${extracted}/iloader.desktop -t $out/share/applications
        install -Dm444 ${extracted}/iloader.png -t $out/share/pixmaps
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
