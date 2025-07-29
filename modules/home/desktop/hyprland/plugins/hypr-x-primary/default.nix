{
  lib,
  config,
  inputs,
  system,
  ...
}:
with lib;
with internal; let
  cfg = config.desktop.hyprland;
  primaryMonitor = findFirst (m: m.primary) null config.hardware.displays;
in {
  config = mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      settings.plugin.xwaylandprimary = {
        display = primaryMonitor.port;
      };
      plugins = [
        inputs.hyprXPrimary.packages.${system}.default
      ];
    };
  };
}
