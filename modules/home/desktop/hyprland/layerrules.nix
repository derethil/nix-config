{
  lib,
  config,
  ...
}:
with lib;
with internal; let
  cfg = config.desktop.hyprland;
in {
  config = mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      settings.layerrule = [
        # AGS Overlays
        "ignorealpha 0.80, overlay-blur"
        "ignorealpha 0.80, overlay-transparent"
        "ignorealpha 0.80, overlay-opaque"
        "unset, overlay-blur"
        "blur, overlay-blur"
        "xray 1, overlay-blur"

        # AGS Popups
        "animation popin 60%, pulse"
        "blur, Bar|Dock|pulse|PopupNotifications"
        "ignorealpha 0.59, Bar|Dock|pulse|PopupNotifications"
        "xray 0, Dock|Bar|pulse|PopupNotifications"

        # Miscellaneous Applications
        "noanim, selection"
        "noanim, hyprpicker "
      ];
    };
  };
}
