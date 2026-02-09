{
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf mkForce;
  cfg = config.glace.desktop.dank-material-shell;

  action' = description: action: {
    hotkey-overlay.title = description;
    action = action;
  };
in {
  config = mkIf (cfg.enable && config.glace.desktop.niri.enable) {
    glace.desktop.niri.binds = {
      defaultAudioBinds = mkForce false;
      defaultBrightnessBinds = mkForce false;
    };

    programs.niri.settings = {
      # Integrate DMS wallpapers onto the overview
      layout.background-color = "transparent";
      layer-rules = [
        {
          matches = [{namespace = "^quickshell$";}];
          place-within-backdrop = true;
        }
      ];

      binds = with config.lib.niri.actions; {
        "Mod+Shift+Slash" = action' "Show Hotkey Overlay" (spawn-sh "dms ipc call keybinds toggle niri");
        "Mod+Slash" = action' "Open Spotlight" (spawn-sh "dms ipc call spotlight toggle");
        "Mod+V" = action' "Open Clipboard" (spawn-sh "dms ipc call clipboard toggle");
        "Mod+M" = action' "Open Process List" (spawn-sh "dms ipc call processlist toggle");
        "Mod+N" = action' "Open Notifications" (spawn-sh "dms ipc call notifications toggle");
        "Mod+Comma" = action' "Open Settings" (spawn-sh "dms ipc call settings toggle");
        "Mod+P" = action' "Open Notepad" (spawn-sh "dms ipc call notepad toggle");
        "Mod+X" = action' "Open Power Menu" (spawn-sh "dms ipc call powermenu toggle");
        "Mod+C" = action' "Open Control Center" (spawn-sh "dms ipc call control-center toggle");
        "Mod+E" = action' "Open Dashboard" (spawn-sh "dms ipc call dash toggle overview");

        "Mod+Alt+L" = action' "Lock Screen" (spawn-sh "dms ipc call lock lock");

        "Print" = action' "Take Screenshot" (spawn-sh "dms screenshot --no-file");
        "Ctrl+Print" = action' "Take Screenshot [File]" (spawn-sh "dms screenshot -d ${config.glace.desktop.niri.screenshots.path}");

        # Volume
        "XF86AudioRaiseVolume" = {
          hotkey-overlay.title = "Increase Volume";
          action = spawn-sh "dms ipc call audio increment 5";
          allow-when-locked = true;
        };
        "XF86AudioLowerVolume" = {
          hotkey-overlay.title = "Decrease Volume";
          action = spawn-sh "dms ipc call audio decrement 5";
          allow-when-locked = true;
        };
        "XF86AudioMute" = {
          hotkey-overlay.title = "Toggle Mute";
          action = spawn-sh "dms ipc call audio mute";
          allow-when-locked = true;
        };
        "XF86AudioMicMute" = {
          hotkey-overlay.title = "Toggle Mic Mute";
          action = spawn-sh "dms ipc call audio micmute";
          allow-when-locked = true;
        };

        # Backlight
        "XF86MonBrightnessUp" = {
          hotkey-overlay.title = "Increase Brightness";
          action = spawn-sh "dms ipc call brightness increment 5 ''";
          allow-when-locked = true;
        };
        "XF86MonBrightnessDown" = {
          hotkey-overlay.title = "Decrease Brightness";
          action = spawn-sh "dms ipc call brightness decrement 5 ''";
          allow-when-locked = true;
        };

        # Media
        "XF86AudioStop" = action' "Stop" (spawn-sh "dms ipc call mpris stop");
        "XF86AudioPause" = action' "Play/Pause" (spawn-sh "dms ipc call mpris playPause");
        "XF86AudioNext" = action' "Next Track" (spawn-sh "dms ipc call mpris next");
        "XF86AudioPrev" = action' "Previous Track" (spawn-sh "dms ipc call mpris previous");
      };
    };
  };
}
