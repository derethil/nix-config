{lib, ...}: {
  perSystem = {
    pkgs,
    system,
    ...
  }:
    lib.optionalAttrs (lib.elem system ["aarch64-darwin" "aarch64-linux" "x86_64-linux"]) {
      packages.iloader = let
        pname = "iloader";
        version = "2.2.6";

        sources = {
          aarch64-darwin = {
            hash = "sha256-Xo0rmVvMeUbtecvxqORd3O5eBnLYQs0LwyxOOghnHb4=";
            url = "https://github.com/nab138/iloader/releases/download/v${version}/iloader-darwin-universal.app.tar.gz";
          };

          aarch64-linux = {
            hash = "sha256-WBQbaGgws/RUgCeFSafn2GXJXpxtITXEW3ypbtAKH4I=";
            url = "https://github.com/nab138/iloader/releases/download/v${version}/iloader-linux-aarch64.AppImage";
          };

          x86_64-linux = {
            hash = "sha256-rLsDVXct9hFu3cyDv5i7NQX820WDxMfFEMfiUPGrOjU=";
            url = "https://github.com/nab138/iloader/releases/download/v${version}/iloader-linux-amd64.AppImage";
          };
        };

        src = pkgs.fetchurl sources.${pkgs.stdenv.hostPlatform.system};

        meta = {
          description = "A user-friendly desktop application for sideloading apps onto iOS devices";
          homepage = "https://github.com/nab138/iloader";
          license = lib.licenses.mit;
          platforms = ["aarch64-darwin" "aarch64-linux" "x86_64-linux"];
        };
      in
        if pkgs.stdenv.isLinux
        then let
          # AppImage bundles incompatible Wayland libraries that cause EGL_BAD_PARAMETER
          # errors; stripping them forces the app to use system libraries.
          # See: https://github.com/nab138/iloader/issues/77
          extracted = pkgs.appimageTools.extract {
            inherit pname src version;

            postExtract = ''
              chmod -R +w $out
              rm -f $out/usr/lib/*wayland*so*
              rm -f $out/usr/lib/im-wayland*.so
            '';
          };

          fhsEnv = pkgs.buildFHSEnv {
            multiPkgs = pkgs.appimageTools.defaultFhsEnvArgs.multiPkgs;
            name = "${pname}-fhs";
            runScript = "${extracted}/AppRun";

            targetPkgs = p:
              (pkgs.appimageTools.defaultFhsEnvArgs.targetPkgs p)
              ++ (with p; [
                libxkbcommon
                wayland
              ]);
          };
        in
          pkgs.stdenv.mkDerivation {
            inherit meta pname version;
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
          pkgs.stdenv.mkDerivation {
            inherit meta pname src version;

            installPhase = ''
              runHook preInstall
              mkdir -p $out/Applications
              cp -r iloader.app $out/Applications/
              runHook postInstall
            '';

            sourceRoot = ".";
          };
    };
}
