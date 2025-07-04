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
  options.desktop.hyprland = {
    enable = mkBoolOpt false "Hyprland desktop environment";
  };

  config = mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      enable = true;
      package = null;
      portalPackage = null;
      plugins = with pkgs; [
        inputs.hyprland-plugins.hyprexpo
      ];
    };
  };
}
