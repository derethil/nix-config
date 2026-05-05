{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf getExe;
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
  inherit (lib.glace) mkBoolOpt;

  cfg = config.glace.apps.gaming.prismlauncher;

  prismlauncher-fhs = pkgs.buildFHSEnv {
    name = "prismlauncher-fhs";

    targetPkgs = pkgs:
      with pkgs; [
        # Package
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
        xorg.libX11
        xorg.libXcomposite
        xorg.libXdamage
        xorg.libXext
        xorg.libXfixes
        xorg.libXi
        xorg.libXrandr
        xorg.libXrender
        xorg.libXScrnSaver
        xorg.libXtst
        xorg.libxcb
        xorg.libxshmfence
      ];

    runScript = "prismlauncher";
  };

  primlauncher-wrapped = pkgs.symlinkJoin {
    name = "prismlauncher";
    paths = [pkgs.prismlauncher prismlauncher-fhs];
    nativeBuildInputs = [pkgs.makeWrapper];
    postBuild = ''
      wrapProgram $out/bin/prismlauncher --run 'exec ${getExe prismlauncher-fhs}'
    '';
  };
in {
  options.glace.apps.gaming.prismlauncher = {
    enable = mkBoolOpt false "Whether to enable Prism Launcher.";
  };

  config = mkIf cfg.enable {
    home.packages = [
      (
        # MacOS can run dynamically linked libraries just fine
        if isDarwin
        then pkgs.prismlauncher
        else primlauncher-wrapped
      )
    ];

    # NOTE: This is needed to use the WayGL mod to force Wayland rendering. Remember to:
    # - Set up the WayGL config file
    # - Change earlyWindowControl to false in /config/fml.toml if using Sinytra & Forge
    home.file.".local/lib/libglfw.so".source = "${pkgs.glfw}/lib/libglfw.so";
  };
}
