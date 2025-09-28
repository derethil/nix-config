{
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf mkForce;
  cfg = config.desktop.dank-material-shell;
in {
  config = mkIf (cfg.enable && config.desktop.hyprland.enable) {
    desktop.hyprland.binds = {
      defaultAudioBinds = mkForce false;
      defaultBrightnessBinds = mkForce false;
    };

    wayland.windowManager.hyprland = {
      settings = {
        bind = [
          "$mod, Slash, exec, dms ipc call spotlight toggle"
          "$mod, V, exec, dms ipc call clipboard toggle"
          "$mod, M, exec, dms ipc call processlist toggle"
          "$mod, N, exec, dms ipc call notifications toggle"
          "$mod, comma, exec, dms ipc call settings toggle"
          "$mod, P, exec, dms ipc call notepad toggle"
          "$mod, X, exec, dms ipc call powermenu toggle"
          "$mod, C, exec, dms ipc call control-center toggle"
          "$mod, D, exec, dms ipc call dash toggle overview"

          "SUPERALT, L, exec, dms ipc call lock lock"
        ];

        bindl = [
          # Volume
          ", XF86AudioRaiseVolume, exec, dms ipc call audio increment 10"
          ", XF86AudioLowerVolume, exec, dms ipc call audio decrement 10"
          ", XF86AudioMute, exec, dms ipc call audio mute"
          ", XF86AudioMicMute, exec, dms ipc call audio micmute"

          #  Backlight
          ", XF86MonBrightnessUp, exec, dms ipc call brightness increment 5 \"\""
          ", XF86MonBrightnessDown, exec, dms ipc call brightness decrement 5 \"\""

          # Media
          ", XF86AudioStop, exec, dms ipc call mpris stop"
          ", XF86AudioPause, exec, dms ipc call mpris playPause"
          ", XF86AudioNext, exec, dms ipc call mpris next"
          ", XF86AudioPrev, exec, dms ipc call mpris previous"
        ];
      };
    };
  };
}
