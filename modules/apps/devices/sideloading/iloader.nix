{lib, ...}: {
  perSystem = {
    pkgs,
    system,
    ...
  }:
    lib.optionalAttrs (lib.elem system ["aarch64-darwin" "aarch64-linux" "x86_64-linux"]) {
      packages.iloader = let
        pname = "iloader";
        release = {
          datasource = "github-releases";
          extractVersion = "^v(?<version>.+)$";
          packageName = "nab138/iloader";
          version = "2.4.1";
          versioning = "semver";
        };

        inherit (release) version;

        sources = {
          aarch64-darwin = {
            # regen-hash-url: packages.aarch64-darwin.iloader.src.url
            hash = "sha256-z0vdJp+RrpFlHNILEBxiFwUr7dOuBurXLvBNYRr8+ls=";
            url = "https://github.com/nab138/iloader/releases/download/v${version}/iloader-darwin-universal.app.tar.gz";
          };

          aarch64-linux = {
            # regen-hash-url: packages.aarch64-linux.iloader.src.url
            hash = "sha256-3DAnGGw9qBGqH0IfSVSLPesm1PyVCQX4s6rh/IwF+P0=";
            url = "https://github.com/nab138/iloader/releases/download/v${version}/iloader-linux-aarch64.AppImage";
          };

          x86_64-linux = {
            # regen-hash-url: packages.x86_64-linux.iloader.src.url
            hash = "sha256-3vp25Pw+fPouYIiCiOFNB25qmcxQs42i2GVigXvNRmM=";
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

            passthru.src = src;
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
