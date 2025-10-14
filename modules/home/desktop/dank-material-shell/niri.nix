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

    programs.niri.settings.binds = with config.lib.niri.actions; {
      "Mod+Slash" = action' "Spotlight" (spawn-sh "dms ipc call spotlight toggle");
      "Mod+V" = action' "Clipboard" (spawn-sh "dms ipc call clipboard toggle");
      "Mod+M" = action' "Process List" (spawn-sh "dms ipc call processlist toggle");
      "Mod+N" = action' "Notifications" (spawn-sh "dms ipc call notifications toggle");
      "Mod+Comma" = action' "Settings" (spawn-sh "dms ipc call settings toggle");
      "Mod+P" = action' "Notepad" (spawn-sh "dms ipc call notepad toggle");
      "Mod+X" = action' "Power Menu" (spawn-sh "dms ipc call powermenu toggle");
      "Mod+C" = action' "Control Center" (spawn-sh "dms ipc call control-center toggle");
      "Mod+D" = action' "Dashboard" (spawn-sh "dms ipc call dash toggle overview");

      "Mod+Alt+L" = action' "Lock Screen" (spawn-sh "dms ipc call lock lock");

      # Volume
      "XF86AudioRaiseVolume" = {
        hotkey-overlay.title = "Increase Volume";
        action = spawn-sh "dms ipc call audio increment 10";
        allow-when-locked = true;
      };
      "XF86AudioLowerVolume" = {
        hotkey-overlay.title = "Decrease Volume";
        action = spawn-sh "dms ipc call audio decrement 10";
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
}

