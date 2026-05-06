{
  lib,
  config,
  inputs,
  ...
}: let
  inherit (lib) mkIf mkForce mkMerge;
  cfg = config.glace.desktop.dank-material-shell;
  dmsLogo = "${inputs.dank-material-shell}/assets/danklogo.svg";

  withProps = props: options:
    mkMerge [
      {
        _props = props;
      }
      options
    ];
in {
  config = mkIf (cfg.enable && config.glace.desktop.niri.enable) {
    glace.desktop.niri.binds = {
      defaultAudioBinds = mkForce false;
      defaultBrightnessBinds = mkForce false;
    };

    wayland.windowManager.niri.settings.binds = {
      # Hotkey Overlay
      "Mod+Shift+Slash" = withProps {hotkey-overlay-title = "Show Hotkey Overlay";} {spawn-sh = "dms ipc call keybinds toggle niri";};

      # Spotlight
      "Mod+Slash" = withProps {hotkey-overlay-title = "Open Spotlight";} {spawn-sh = "dms ipc call spotlight toggle";};
      "Mod+I" = withProps {hotkey-overlay-title = "Open Spotlight [Emoji]";} {spawn-sh = "dms ipc call spotlight toggleQuery ':e'";};

      # Modal Toggles
      "Mod+V" = withProps {hotkey-overlay-title = "Open Clipboard";} {spawn-sh = "dms ipc call clipboard toggle";};
      "Mod+M" = withProps {hotkey-overlay-title = "Open Process List";} {spawn-sh = "dms ipc call processlist toggle";};
      "Mod+N" = withProps {hotkey-overlay-title = "Open Notifications";} {spawn-sh = "dms ipc call notifications toggle";};
      "Mod+Semicolon" = withProps {hotkey-overlay-title = "Open Settings";} {spawn-sh = "dms ipc call settings toggle";};
      "Mod+P" = withProps {hotkey-overlay-title = "Open Notepad";} {spawn-sh = "dms ipc call notepad toggle";};
      "Mod+X" = withProps {hotkey-overlay-title = "Open Power Menu";} {spawn-sh = "dms ipc call powermenu toggle";};
      "Mod+C" = withProps {hotkey-overlay-title = "Open Control Center";} {spawn-sh = "dms ipc call control-center toggle";};
      "Mod+E" = withProps {hotkey-overlay-title = "Open Dashboard";} {spawn-sh = "dms ipc call dash toggle overview";};

      # Keybinds
      "Mod+Shift+I" = withProps {hotkey-overlay-title = "Toggle Idle Inhibitor";} {spawn-sh = "dms notify --app 'Idle Inhibitor' --icon '${dmsLogo}' \"$(dms ipc call inhibit toggle)\"";};

      # Lock Screen
      "Mod+Alt+L" = withProps {hotkey-overlay-title = "Lock Screen";} {spawn-sh = "dms ipc call lock lock";};

      # Screenshots
      "Print" = withProps {hotkey-overlay-title = "Take Screenshot";} {spawn-sh = "dms screenshot --no-file";};
      "Ctrl+Print" = withProps {hotkey-overlay-title = "Take Screenshot [File]";} {spawn-sh = "dms screenshot -d ${config.glace.desktop.niri.screenshots.path}";};

      # Volume
      "XF86AudioRaiseVolume" = withProps {
        hotkey-overlay-title = "Increase Volume";
        allow-when-locked = true;
      } {spawn-sh = "dms ipc call audio increment 5";};

      "XF86AudioLowerVolume" = withProps {
        hotkey-overlay-title = "Decrease Volume";
        allow-when-locked = true;
      } {spawn-sh = "dms ipc call audio decrement 5";};

      "XF86AudioMute" = withProps {
        hotkey-overlay-title = "Toggle Mute";
        allow-when-locked = true;
      } {spawn-sh = "dms ipc call audio mute";};

      "XF86AudioMicMute" = withProps {
        hotkey-overlay-title = "Toggle Mic Mute";
        allow-when-locked = true;
      } {spawn-sh = "dms ipc call audio micmute";};

      # Backlight
      "XF86MonBrightnessUp" = withProps {
        hotkey-overlay-title = "Increase Brightness";
        allow-when-locked = true;
      } {spawn-sh = "dms ipc call brightness increment 5 ''";};

      "XF86MonBrightnessDown" = withProps {
        hotkey-overlay-title = "Decrease Brightness";
        allow-when-locked = true;
      } {spawn-sh = "dms ipc call brightness decrement 5 ''";};

      # Media
      "XF86AudioStop" = withProps {hotkey-overlay-title = "Stop";} {spawn-sh = "dms ipc call mpris stop";};
      "XF86AudioPause" = withProps {hotkey-overlay-title = "Play/Pause";} {spawn-sh = "dms ipc call mpris playPause";};
      "XF86AudioNext" = withProps {hotkey-overlay-title = "Next Track";} {spawn-sh = "dms ipc call mpris next";};
      "XF86AudioPrev" = withProps {hotkey-overlay-title = "Previous Track";} {spawn-sh = "dms ipc call mpris previous";};
    };

    # Integrate DMS wallpapers onto the overview
    wayland.windowManager.niri.settings = {
      layer-rule = [
        {
          match._props = {namespace = "^quickshell$";};
          place-within-backdrop = true;
        }
      ];
    };
  };
}
