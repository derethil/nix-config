{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.apps.gaming.prismlauncher;
in {
  options.glace.apps.gaming.prismlauncher = {
    enable = mkBoolOpt false "Whether to enable Prism Launcher.";
  };

  config = mkIf cfg.enable {
    home.packages = [pkgs.prismlauncher];

    # NOTE: This is needed to use the WayGL mod to force Wayland rendering. Remember to:
    # - Set up the WayGL config file
    # - Change earlyWindowControl to false in /config/fml.toml if using Sinytra & Forge
    home.file.".local/lib/libglfw.so".source = "${pkgs.glfw}/lib/libglfw.so";
  };
}
