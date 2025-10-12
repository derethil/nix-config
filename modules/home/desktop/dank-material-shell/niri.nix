{
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf mkForce;
  cfg = config.glace.desktop.dank-material-shell;
in {
  config = mkIf (cfg.enable && config.glace.desktop.niri.enable) {
    glace.desktop.niri.binds = {
      defaultAudioBinds = mkForce false;
      defaultBrightnessBinds = mkForce false;
    };

    programs.niri.settings.binds = with config.lib.niri.actions; {
      "Mod+Slash".action = spawn-sh "dms ipc call spotlight toggle";
      "Mod+V".action = spawn-sh "dms ipc call clipboard toggle";
      "Mod+M".action = spawn-sh "dms ipc call processlist toggle";
      "Mod+N".action = spawn-sh "dms ipc call notifications toggle";
      "Mod+Comma".action = spawn-sh "dms ipc call settings toggle";
      "Mod+P".action = spawn-sh "dms ipc call notepad toggle";
      "Mod+X".action = spawn-sh "dms ipc call powermenu toggle";
      "Mod+C".action = spawn-sh "dms ipc call control-center toggle";
      "Mod+D".action = spawn-sh "dms ipc call dash toggle overview";

      "Mod+Alt+L".action = spawn-sh "dms ipc call lock lock";

      # Volume
      "XF86AudioRaiseVolume" = {
        action = spawn-sh "dms ipc call audio increment 10";
        allow-when-locked = true;
      };
      "XF86AudioLowerVolume" = {
        action = spawn-sh "dms ipc call audio decrement 10";
        allow-when-locked = true;
      };
      "XF86AudioMute" = {
        action = spawn-sh "dms ipc call audio mute";
        allow-when-locked = true;
      };
      "XF86AudioMicMute" = {
        action = spawn-sh "dms ipc call audio micmute";
        allow-when-locked = true;
      };

      # Backlight
      "XF86MonBrightnessUp" = {
        action = spawn-sh "dms ipc call brightness increment 5 ''";
        allow-when-locked = true;
      };
      "XF86MonBrightnessDown" = {
        action = spawn-sh "dms ipc call brightness decrement 5 ''";
        allow-when-locked = true;
      };

      # Media
      "XF86AudioStop".action = spawn-sh "dms ipc call mpris stop";
      "XF86AudioPause".action = spawn-sh "dms ipc call mpris playPause";
      "XF86AudioNext".action = spawn-sh "dms ipc call mpris next";
      "XF86AudioPrev".action = spawn-sh "dms ipc call mpris previous";
    };
  };
}