{
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.glace.desktop.hyprland;
in {
  config = mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      settings.layerrule = [
        "noanim, selection"
        "noanim, hyprpicker "
      ];
    };
  };
}
