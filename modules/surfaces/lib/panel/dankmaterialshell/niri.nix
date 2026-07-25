{
  self,
  inputs,
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
      niri-nix
      niri-options
    ];

    surfaces.niri = {
      binds = {
        defaultAudioBinds = mkForce false;
        defaultBrightnessBinds = mkForce false;
      };

      layout.defaultColors = mkForce false;
    };

    wayland.windowManager.niri.settings = {
      binds = {
        # Lock Screen
        "Ctrl+Alt+L" = mkKeybinds {hotkey-overlay-title = "Lock Screen";} {spawn-sh = "dms ipc call lock lock";};
        "Ctrl+Print" = mkKeybinds {hotkey-overlay-title = "Take Screenshot [File]";} {spawn-sh = "dms screenshot -d ${config.surfaces.niri.screenshots.path}";};
        "Mod+C" = mkKeybinds {hotkey-overlay-title = "Open Control Center";} {spawn-sh = "dms ipc call control-center toggle";};
        "Mod+E" = mkKeybinds {hotkey-overlay-title = "Open Dashboard";} {spawn-sh = "dms ipc call dash toggle overview";};
        "Mod+I" = mkKeybinds {hotkey-overlay-title = "Open Spotlight [Emoji]";} {spawn-sh = "dms ipc call spotlight toggleQuery 'e'";};
        "Mod+N" = mkKeybinds {hotkey-overlay-title = "Open Notifications";} {spawn-sh = "dms ipc call notifications toggle";};
        "Mod+P" = mkKeybinds {hotkey-overlay-title = "Open Notepad";} {spawn-sh = "dms ipc call notepad toggle";};
        "Mod+Semicolon" = mkKeybinds {hotkey-overlay-title = "Open Settings";} {spawn-sh = "dms ipc call settings toggle";};
        # Keybinds
        "Mod+Shift+I" = mkKeybinds {hotkey-overlay-title = "Toggle Idle Inhibitor";} {spawn-sh = "dms notify --app 'Idle Inhibitor' --icon '${dmsLogo}' \"$(dms ipc call inhibit toggle)\"";};
        # Hotkey Overlay
        "Mod+Shift+Slash" = mkKeybinds {hotkey-overlay-title = "Show Hotkey Overlay";} {spawn-sh = "dms ipc call keybinds toggle niri";};
        # Spotlight
        "Mod+Slash" = mkKeybinds {hotkey-overlay-title = "Open Spotlight";} {spawn-sh = "dms ipc call spotlight toggle";};
        "Mod+T" = mkKeybinds {hotkey-overlay-title = "Open Process List";} {spawn-sh = "dms ipc call processlist toggle";};
        # Modal Toggles
        "Mod+V" = mkKeybinds {hotkey-overlay-title = "Open Clipboard";} {spawn-sh = "dms ipc call clipboard toggle";};
        "Mod+X" = mkKeybinds {hotkey-overlay-title = "Open Power Menu";} {spawn-sh = "dms ipc call powermenu toggle";};
        # Screenshots
        "Print" = mkKeybinds {hotkey-overlay-title = "Take Screenshot";} {spawn-sh = "dms screenshot --no-file";};

        "XF86AudioLowerVolume" = mkKeybinds {
          allow-when-locked = true;
          hotkey-overlay-title = "Decrease Volume";
        } {spawn-sh = "dms ipc call audio decrement 5";};

        "XF86AudioMicMute" = mkKeybinds {
          allow-when-locked = true;
          hotkey-overlay-title = "Toggle Mic Mute";
        } {spawn-sh = "dms ipc call audio micmute";};

        "XF86AudioMute" = mkKeybinds {
          allow-when-locked = true;
          hotkey-overlay-title = "Toggle Mute";
        } {spawn-sh = "dms ipc call audio mute";};

        "XF86AudioNext" = mkKeybinds {hotkey-overlay-title = "Next Track";} {spawn-sh = "dms ipc call mpris next";};
        "XF86AudioPause" = mkKeybinds {hotkey-overlay-title = "Play/Pause";} {spawn-sh = "dms ipc call mpris playPause";};
        "XF86AudioPrev" = mkKeybinds {hotkey-overlay-title = "Previous Track";} {spawn-sh = "dms ipc call mpris previous";};

        # Volume
        "XF86AudioRaiseVolume" = mkKeybinds {
          allow-when-locked = true;
          hotkey-overlay-title = "Increase Volume";
        } {spawn-sh = "dms ipc call audio increment 5";};

        # Media
        "XF86AudioStop" = mkKeybinds {hotkey-overlay-title = "Stop";} {spawn-sh = "dms ipc call mpris stop";};

        "XF86MonBrightnessDown" = mkKeybinds {
          allow-when-locked = true;
          hotkey-overlay-title = "Decrease Brightness";
        } {spawn-sh = "dms ipc call brightness decrement 5 ''";};

        # Backlight
        "XF86MonBrightnessUp" = mkKeybinds {
          allow-when-locked = true;
          hotkey-overlay-title = "Increase Brightness";
        } {spawn-sh = "dms ipc call brightness increment 5 ''";};
      };

      include = [
        {_args = ["dms/colors.kdl"];}
        {_args = ["dms/wpblur.kdl"];}
      ];

      layer-rule = [
        {
          match._props.namespace = "^quickshell$";
          place-within-backdrop = true;
        }
      ];
    };
  };
}
