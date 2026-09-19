{
  self,
  lib,
  ...
}: {
  flake.modules.homeManager.noctalia-panel-niri = let
    inherit (self.lib.niri) mkKeybinds;
  in {
    imports = with self.modules.homeManager; [
      niri-nix
      niri-options
      openhue
    ];

    surfaces.niri = {
      binds = {
        defaultAudioBinds = lib.mkForce false;
        defaultBrightnessBinds = lib.mkForce false;
      };

      layout.defaultColors = lib.mkForce false;
    };

    wayland.windowManager.niri.settings = {
      binds = {
        "Ctrl+Alt+L" = mkKeybinds {hotkey-overlay-title = "Lock Screen";} {spawn-sh = "noctalia msg session lock";};
        "Ctrl+Print" = mkKeybinds {hotkey-overlay-title = "Take Screenshot [Fullscreen]";} {spawn-sh = "noctalia msg screenshot-fullscreen";};
        "Ctrl+Shift+Print" = mkKeybinds {hotkey-overlay-title = "Take Screenshot [Annotate]";} {spawn-sh = "noctalia msg screenshot-annotate";};
        "Mod+C" = mkKeybinds {hotkey-overlay-title = "Open Control Center";} {spawn-sh = "noctalia msg panel-toggle control-center";};
        "Mod+I" = mkKeybinds {hotkey-overlay-title = "Open Emoji Picker";} {spawn-sh = "noctalia msg panel-toggle liamwh/emoji-picker:wide";};
        "Mod+N" = mkKeybinds {hotkey-overlay-title = "Open Notifications";} {spawn-sh = "noctalia msg panel-toggle control-center notifications";};
        "Mod+P" = mkKeybinds {hotkey-overlay-title = "Open Passwords";} {spawn-sh = "noctalia msg panel-toggle launcher '/bw '";};
        "Mod+Semicolon" = mkKeybinds {hotkey-overlay-title = "Open Settings";} {spawn-sh = "noctalia msg settings-toggle";};
        "Mod+Shift+I" = mkKeybinds {hotkey-overlay-title = "Toggle Idle Inhibitor";} {spawn-sh = "noctalia msg caffeine-toggle";};
        "Mod+Shift+Slash" = mkKeybinds {hotkey-overlay-title = "Show Hotkey Overlay";} {spawn-sh = "noctalia msg panel-toggle kenn/keybind-cheatsheet:cheatsheet";};
        "Mod+Slash" = mkKeybinds {hotkey-overlay-title = "Open Launcher";} {spawn-sh = "noctalia msg panel-toggle launcher";};
        "Mod+V" = mkKeybinds {hotkey-overlay-title = "Open Clipboard";} {spawn-sh = "noctalia msg panel-toggle clipboard";};
        "Mod+X" = mkKeybinds {hotkey-overlay-title = "Open Power Menu";} {spawn-sh = "noctalia msg panel-toggle session";};
        "Print" = mkKeybinds {hotkey-overlay-title = "Take Screenshot";} {spawn-sh = "noctalia msg screenshot-region";};

        "XF86AudioLowerVolume" = mkKeybinds {
          allow-when-locked = true;
          hotkey-overlay-title = "Decrease Volume";
        } {spawn-sh = "noctalia msg volume-down";};

        "XF86AudioMicMute" = mkKeybinds {
          allow-when-locked = true;
          hotkey-overlay-title = "Toggle Mic Mute";
        } {spawn-sh = "noctalia msg mic-mute";};

        "XF86AudioMute" = mkKeybinds {
          allow-when-locked = true;
          hotkey-overlay-title = "Toggle Mute";
        } {spawn-sh = "noctalia msg volume-mute";};

        "XF86AudioNext" = mkKeybinds {hotkey-overlay-title = "Next Track";} {spawn-sh = "noctalia msg media next";};
        "XF86AudioPause" = mkKeybinds {hotkey-overlay-title = "Play/Pause";} {spawn-sh = "noctalia msg media toggle";};
        "XF86AudioPrev" = mkKeybinds {hotkey-overlay-title = "Previous Track";} {spawn-sh = "noctalia msg media previous";};

        "XF86AudioRaiseVolume" = mkKeybinds {
          allow-when-locked = true;
          hotkey-overlay-title = "Increase Volume";
        } {spawn-sh = "noctalia msg volume-up";};

        "XF86AudioStop" = mkKeybinds {hotkey-overlay-title = "Stop";} {spawn-sh = "noctalia msg media stop";};

        "XF86MonBrightnessDown" = mkKeybinds {
          allow-when-locked = true;
          hotkey-overlay-title = "Decrease Brightness";
        } {spawn-sh = "noctalia msg brightness-down";};

        "XF86MonBrightnessUp" = mkKeybinds {
          allow-when-locked = true;
          hotkey-overlay-title = "Increase Brightness";
        } {spawn-sh = "noctalia msg brightness-up";};
      };

      layer-rule = [
        {
          match._props.namespace = "^noctalia-backdrop";
          place-within-backdrop = true;
        }
      ];

      window-rule = [
        {
          default-column-width.fixed = 1080;
          default-window-height.fixed = 920;
          match._props.app-id = "dev.noctalia.Noctalia";
          open-floating = true;
        }
      ];
    };
  };
}
