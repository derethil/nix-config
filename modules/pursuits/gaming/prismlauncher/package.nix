{lib, ...}: {
  perSystem = {
    system,
    pkgs,
    ...
  }:
    lib.optionalAttrs (lib.elem system lib.platforms.linux) {
      packages.prismlauncher = let
        prismlauncher-fhs = pkgs.buildFHSEnv {
          name = "prismlauncher-fhs";

          targetPkgs = p:
            with p; [
              prismlauncher

              # For watermedia (embedded VLC)
              libvlc

              # For MCEF (embedded Chromium)
              alsa-lib
              atk
              at-spi2-atk
              cairo
              cups
              dbus
              expat
              glib
              gtk3
              libdrm
              libgbm
              libxkbcommon
              mesa
              nspr
              nss
              pango
              libx11
              libxcomposite
              libxdamage
              libxext
              libxfixes
              libxi
              libxrandr
              libxrender
              libxscrnsaver
              libxtst
              libxcb
              libxshmfence
            ];

          runScript = "prismlauncher";
        };
      in
        pkgs.symlinkJoin {
          name = "prismlauncher";
          paths = [pkgs.prismlauncher prismlauncher-fhs];
          nativeBuildInputs = [pkgs.makeWrapper];
          postBuild = ''
            wrapProgram $out/bin/prismlauncher --run 'exec ${lib.getExe prismlauncher-fhs}'
          '';
        };
    };
}
