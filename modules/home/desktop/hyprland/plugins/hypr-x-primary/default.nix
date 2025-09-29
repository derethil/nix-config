{
  lib,
  config,
  inputs,
  system,
  ...
}:
with lib;
with glace; let
  cfg = config.glace.desktop.hyprland;
  primaryMonitor = findFirst (m: m.primary) null config.glace.hardware.displays;
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
