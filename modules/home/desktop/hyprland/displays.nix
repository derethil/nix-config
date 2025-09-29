{
  lib,
  config,
  ...
}:
with lib;
with lib.glace; let
  cfg = config.glace.desktop.hyprland;
  displays = config.glace.hardware.displays;
  primaryDisplay = findFirst (d: d.primary) null displays;

  toHyprlandMonitor = d: let
    # Required parameters
    position = "${toString d.position.x}x${toString d.position.y}";
    refreshRate = "${d.resolution}@${toString d.framerate}";
    scale = toString d.scale;
    port =
      if d.port != null
      then d.port
      else "";

    # Optional parameters
    rotationParam =
      if d.rotation != "0"
      then ",transform,${d.rotation}"
      else "";
    vrrParam =
      if d.vrr != 0
      then ",vrr,${toString d.vrr}"
      else "";
    #
    # Format the monitor string
  in "${port},${refreshRate},${position},${scale}${rotationParam}${vrrParam}";
in {
  config = mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      settings = {
        monitor = map toHyprlandMonitor (filter (d: d.enabled) displays);
        cursor.default_monitor = primaryDisplay.port;
      };
    };
  };
}
