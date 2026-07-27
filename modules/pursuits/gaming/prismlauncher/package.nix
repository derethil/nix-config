{lib, ...}: {
  perSystem = {
    pkgs,
    system,
    ...
  }:
    lib.optionalAttrs (lib.elem system lib.platforms.linux) {
      packages.prismlauncher = let
        prismlauncher-fhs = pkgs.buildFHSEnv {
          name = "prismlauncher-fhs";
          runScript = "prismlauncher";

          targetPkgs = p:
            with p; [
              alsa-lib
              at-spi2-atk
              atk
              cairo
              cups
              dbus
              expat
              glib
              gtk3
              libdrm
              libgbm
              libvlc
              libx11
              libxcb
              libxcomposite
              libxdamage
              libxext
              libxfixes
              libxi
              libxkbcommon
              libxrandr
              libxrender
              libxscrnsaver
              libxshmfence
              libxtst
              mesa
              nspr
              nss
              pango
              prismlauncher
            ];
        };
      in
        pkgs.symlinkJoin {
          name = "prismlauncher";
          nativeBuildInputs = [pkgs.makeWrapper];
          paths = [pkgs.prismlauncher prismlauncher-fhs];

          postBuild = ''
            wrapProgram $out/bin/prismlauncher --run 'exec ${lib.getExe prismlauncher-fhs}'
          '';
        };
    };
}
