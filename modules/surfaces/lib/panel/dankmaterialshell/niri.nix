{
  inputs,
  self,
  ...
}: {
  flake.modules.homeManager.dankmaterialshell-panel-niri = {
    config,
    lib,
    ...
  }: let
    inherit (lib) mkForce;
    inherit (self.lib.niri) mkKeybinds;
    dmsLogo = "${inputs.dank-material-shell}/assets/danklogo.svg";
  in {
    imports = with self.modules.homeManager; [
      niri-options
      niri-nix
    ];

    surfaces.niri = {
      layout.defaultColors = mkForce false;
      binds = {
        defaultAudioBinds = mkForce false;
        defaultBrightnessBinds = mkForce false;
      };
    };

    wayland.windowManager.niri.settings = {
      include = [
        {_args = ["dms/colors.kdl"];}
        {_args = ["dms/wpblur.kdl"];}
      ];

      binds = {
        # Hotkey Overlay
        "Mod+Shift+Slash" = mkKeybinds {hotkey-overlay-title = "Show Hotkey Overlay";} {spawn-sh = "dms ipc call keybinds toggle niri";};

        # Spotlight
        "Mod+Slash" = mkKeybinds {hotkey-overlay-title = "Open Spotlight";} {spawn-sh = "dms ipc call spotlight toggle";};
        "Mod+I" = mkKeybinds {hotkey-overlay-title = "Open Spotlight [Emoji]";} {spawn-sh = "dms ipc call spotlight toggleQuery ':e'";};

        # Modal Toggles
        "Mod+V" = mkKeybinds {hotkey-overlay-title = "Open Clipboard";} {spawn-sh = "dms ipc call clipboard toggle";};
        "Mod+T" = mkKeybinds {hotkey-overlay-title = "Open Process List";} {spawn-sh = "dms ipc call processlist toggle";};
        "Mod+N" = mkKeybinds {hotkey-overlay-title = "Open Notifications";} {spawn-sh = "dms ipc call notifications toggle";};
        "Mod+Semicolon" = mkKeybinds {hotkey-overlay-title = "Open Settings";} {spawn-sh = "dms ipc call settings toggle";};
        "Mod+P" = mkKeybinds {hotkey-overlay-title = "Open Notepad";} {spawn-sh = "dms ipc call notepad toggle";};
        "Mod+X" = mkKeybinds {hotkey-overlay-title = "Open Power Menu";} {spawn-sh = "dms ipc call powermenu toggle";};
        "Mod+C" = mkKeybinds {hotkey-overlay-title = "Open Control Center";} {spawn-sh = "dms ipc call control-center toggle";};
        "Mod+E" = mkKeybinds {hotkey-overlay-title = "Open Dashboard";} {spawn-sh = "dms ipc call dash toggle overview";};

        # Keybinds
        "Mod+Shift+I" = mkKeybinds {hotkey-overlay-title = "Toggle Idle Inhibitor";} {spawn-sh = "dms notify --app 'Idle Inhibitor' --icon '${dmsLogo}' \"$(dms ipc call inhibit toggle)\"";};

        # Lock Screen
        "Ctrl+Alt+L" = mkKeybinds {hotkey-overlay-title = "Lock Screen";} {spawn-sh = "dms ipc call lock lock";};

        # Screenshots
        "Print" = mkKeybinds {hotkey-overlay-title = "Take Screenshot";} {spawn-sh = "dms screenshot --no-file";};
        "Ctrl+Print" = mkKeybinds {hotkey-overlay-title = "Take Screenshot [File]";} {spawn-sh = "dms screenshot -d ${config.surfaces.niri.screenshots.path}";};

        # Volume
        "XF86AudioRaiseVolume" = mkKeybinds {
          hotkey-overlay-title = "Increase Volume";
          allow-when-locked = true;
        } {spawn-sh = "dms ipc call audio increment 5";};

        "XF86AudioLowerVolume" = mkKeybinds {
          hotkey-overlay-title = "Decrease Volume";
          allow-when-locked = true;
        } {spawn-sh = "dms ipc call audio decrement 5";};

        "XF86AudioMute" = mkKeybinds {
          hotkey-overlay-title = "Toggle Mute";
          allow-when-locked = true;
        } {spawn-sh = "dms ipc call audio mute";};

        "XF86AudioMicMute" = mkKeybinds {
          hotkey-overlay-title = "Toggle Mic Mute";
          allow-when-locked = true;
        } {spawn-sh = "dms ipc call audio micmute";};

        # Backlight
        "XF86MonBrightnessUp" = mkKeybinds {
          hotkey-overlay-title = "Increase Brightness";
          allow-when-locked = true;
        } {spawn-sh = "dms ipc call brightness increment 5 ''";};

        "XF86MonBrightnessDown" = mkKeybinds {
          hotkey-overlay-title = "Decrease Brightness";
          allow-when-locked = true;
        } {spawn-sh = "dms ipc call brightness decrement 5 ''";};

        # Media
        "XF86AudioStop" = mkKeybinds {hotkey-overlay-title = "Stop";} {spawn-sh = "dms ipc call mpris stop";};
        "XF86AudioPause" = mkKeybinds {hotkey-overlay-title = "Play/Pause";} {spawn-sh = "dms ipc call mpris playPause";};
        "XF86AudioNext" = mkKeybinds {hotkey-overlay-title = "Next Track";} {spawn-sh = "dms ipc call mpris next";};
        "XF86AudioPrev" = mkKeybinds {hotkey-overlay-title = "Previous Track";} {spawn-sh = "dms ipc call mpris previous";};
      };

      layer-rule = [
        {
          match._props.namespace = "^quickshell$";
          place-within-backdrop = true;
        }
      ];
    };
  };
}
