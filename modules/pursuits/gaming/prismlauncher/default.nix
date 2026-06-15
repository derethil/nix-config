{lib, ...}: {
  flake.modules.homeManager.prismlauncher = {pkgs, ...}: {
    home.packages = [
      (
        if pkgs.stdenv.hostPlatform.isDarwin
        then pkgs.prismlauncher
        else pkgs.internal.prismlauncher
      )
    ];

    # Needed to use the WayGL mod to force Wayland rendering. Remember to:
    # - Set up the WayGL config file
    # - Change earlyWindowControl to false in /config/fml.toml if using Sinytra & Forge
    home.file = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
      ".local/lib/libglfw.so".source = "${pkgs.glfw}/lib/libglfw.so";
    };
  };
}
