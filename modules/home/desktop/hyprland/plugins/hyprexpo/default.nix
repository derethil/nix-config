{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
with internal; let
  cfg = config.desktop.hyprland;
in {
  config = mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      settings.plugin.hyprexpo = {
        columns = 3;
        gap_size = 2;
        bg_color = "rgba(00000000)";
        workspace_method = "first 1";
        enable_gestures = true;
        gesture_distance = 300;
        gesture_positive = true;
      };
      plugins = mkIf (cfg.withPackage) [
        pkgs.inputs.hyprland-plugins.hyprexpo
      ];
    };
  };
}
