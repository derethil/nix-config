{lib, ...}: {
  perSystem = {
    system,
    pkgs,
    ...
  }:
    lib.optionalAttrs (lib.elem system ["x86_64-linux" "aarch64-linux" "aarch64-darwin"]) {
      packages.iloader = let
        pname = "iloader";
        version = "2.2.6";

        sources = {
          x86_64-linux = {
            url = "https://github.com/nab138/iloader/releases/download/v${version}/iloader-linux-amd64.AppImage";
            hash = "sha256-rLsDVXct9hFu3cyDv5i7NQX820WDxMfFEMfiUPGrOjU=";
          };

          aarch64-linux = {
            url = "https://github.com/nab138/iloader/releases/download/v${version}/iloader-linux-aarch64.AppImage";
            hash = "sha256-WBQbaGgws/RUgCeFSafn2GXJXpxtITXEW3ypbtAKH4I=";
          };

          aarch64-darwin = {
            url = "https://github.com/nab138/iloader/releases/download/v${version}/iloader-darwin-universal.app.tar.gz";
            hash = "sha256-Xo0rmVvMeUbtecvxqORd3O5eBnLYQs0LwyxOOghnHb4=";
          };
        };

        src = pkgs.fetchurl sources.${pkgs.stdenv.hostPlatform.system};

        meta = {
          description = "A user-friendly desktop application for sideloading apps onto iOS devices";
          homepage = "https://github.com/nab138/iloader";
          license = lib.licenses.mit;
          platforms = ["x86_64-linux" "aarch64-linux" "aarch64-darwin"];
        };
      in
        if pkgs.stdenv.isLinux
        then let
          # AppImage bundles incompatible Wayland libraries that cause EGL_BAD_PARAMETER
          # errors; stripping them forces the app to use system libraries.
          # See: https://github.com/nab138/iloader/issues/77
          extracted = pkgs.appimageTools.extract {
            inherit pname version src;
            postExtract = ''
              chmod -R +w $out
              rm -f $out/usr/lib/*wayland*so*
              rm -f $out/usr/lib/im-wayland*.so
            '';
          };

          fhsEnv = pkgs.buildFHSEnv {
            name = "${pname}-fhs";
            targetPkgs = p:
              (pkgs.appimageTools.defaultFhsEnvArgs.targetPkgs p)
              ++ (with p; [
                wayland
                libxkbcommon
              ]);
            multiPkgs = pkgs.appimageTools.defaultFhsEnvArgs.multiPkgs;
            runScript = "${extracted}/AppRun";
          };
        in
          pkgs.stdenv.mkDerivation {
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
          pkgs.stdenv.mkDerivation {
            inherit pname version src meta;

            sourceRoot = ".";

            installPhase = ''
              runHook preInstall
              mkdir -p $out/Applications
              cp -r iloader.app $out/Applications/
              runHook postInstall
            '';
          };
    };
}
