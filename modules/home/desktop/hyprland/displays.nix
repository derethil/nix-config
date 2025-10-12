{
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf findFirst filter;
  cfg = config.glace.desktop.hyprland;
  displays = config.glace.hardware.displays;
  primaryDisplay = findFirst (d: d.primary) null displays;

  toHyprlandMonitor = d: let
    # Required parameters
    position = "${toString d.position.x}x${toString d.position.y}";
    refreshRate = "${toString d.resolution.width}x${toString d.resolution.height}@${toString d.framerate}";
    scale = toString d.scale;
    port =
      if d.port != null
      then d.port
      else "";

    # Optional parameters
    transform =
      # hyprland what the fuck is this syntax why not make a new option
      if d.flipped
      then
        if d.rotation == 0
        then 4
        else if d.rotation == 90
        then 5
        else if d.rotation == 180
        then 6
        else 7 # 270
      else if d.rotation == 0
      then 0
      else if d.rotation == 90
      then 1
      else if d.rotation == 180
      then 2
      else 3; # 270

    rotationParam =
      if transform != 0
      then ",transform,${toString transform}"
      else "";
    vrrParam =
      if d.vrr == true
      then ",vrr,1"
      else if d.vrr == "on-demand"
      then ",vrr,2"
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
