{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkMerge getExe;
  cfg = config.glace.desktop.niri;

  withProps = props: options:
    mkMerge [
      {
        _props = props;
      }
      options
    ];

  mkWorkspaceBinds = modifier: action:
    builtins.listToAttrs (builtins.map (
      i: let
        key =
          if i == 10
          then 0
          else i;
      in {
        name = "${modifier}+${toString key}";
        value = {"${action}" = i;};
      }
    ) (lib.range 1 10));

  mkMenu = menu: let
    font = config.glace.system.fonts.default.monospace;

    configFile =
      builtins.toFile "config.yaml"
      (lib.generators.toYAML {} {
        inherit menu;
        font = "${font.name} ${builtins.toString font.size}";
        anchor = "center";
        background = "#282828";
        color = "#D4BE98";
        corner_r = 6;
        border_width = 2;
        inhibit_compositor_keyboard_shortcuts = true;
      });
  in
    pkgs.writeShellScriptBin "wlr-which-key-menu" ''
      exec ${lib.getExe pkgs.wlr-which-key} ${configFile}
    '';
in {
  config = mkIf cfg.enable {
    wayland.windowManager.niri.settings.binds = mkMerge [
      {
        # Overview
        "Mod+Tab" = {toggle-overview = [];};

        # Exit Session
        "Mod+Shift+E" = withProps {hotkey-overlay-title = "Exit Session";} (
          if config.glace.desktop.uwsm.enable
          then {spawn-sh = ["uwsm" "stop"];}
          else {quit = {_props = {skip-confirmation = true;};};}
        );

        # Builtin Hotkey Overlay
        "Mod+Shift+Slash" = mkIf (!config.glace.desktop.dank-material-shell.enable) (
          withProps {hotkey-overlay-title = "Show Hotkey Overlay";} {
            spawn-sh = ["niri" "msg" "action" "show-hotkey-overlay"];
          }
        );

        # Window State Management
        "Mod+Q" = {close-window = [];};
        "Mod+F" = {fullscreen-window = [];};
        "Mod+Shift+F" = {toggle-windowed-fullscreen = [];};
        "Mod+M" = {maximize-window-to-edges = [];};
        "Mod+Space" = {switch-focus-between-floating-and-tiling = [];};
        "Mod+Shift+Space" = {toggle-window-floating = [];};
        "Mod+MouseForward" = {toggle-window-floating = [];};

        # Focus Windows
        "Mod+Comma" = {focus-column-first = [];};
        "Mod+Period" = {focus-column-last = [];};
        "Mod+H" = {focus-column-left = [];};
        "Mod+L" = {focus-column-right = [];};
        "Mod+K" = {focus-window-up = [];};
        "Mod+J" = {focus-window-down = [];};

        # Move within Workspace
        "Mod+Shift+Comma" = {move-column-to-first = [];};
        "Mod+Shift+Period" = {move-column-to-last = [];};
        "Mod+Shift+H" = {move-column-left = [];};
        "Mod+Shift+L" = {move-column-right = [];};
        "Mod+Shift+K" = {move-window-up = [];};
        "Mod+Shift+J" = {move-window-down = [];};
        "Mod+Ctrl+H" = {consume-or-expel-window-left = [];};
        "Mod+Ctrl+L" = {consume-or-expel-window-right = [];};

        # Resize
        "Mod+S" = {toggle-column-tabbed-display = [];};
        "Mod+R" = withProps {hotkey-overlay-title = "Resize Column";} {
          spawn-sh = [
            (getExe (mkMenu [
              {
                key = "s";
                desc = "1/3 width";
                cmd = "niri msg action set-column-width 33%";
              }
              {
                key = "d";
                desc = "1/2 width";
                cmd = "niri msg action set-column-width 50%";
              }
              {
                key = "f";
                desc = "2/3 width";
                cmd = "niri msg action set-column-width 67%";
              }
              {
                key = "g";
                desc = "Full width";
                cmd = "niri msg action set-column-width 100%";
              }
            ]))
          ];
        };
      }

      # Focus Workspace
      (let
        smart-workspace = getExe pkgs.inputs.niri-smart-workspace.default;
      in
        mkIf cfg.binds.useSmartWorkspaceBinds {
          "Mod+BracketLeft" = {spawn-sh = "${smart-workspace} up";};
          "Mod+BracketRight" = {spawn-sh = "${smart-workspace} down";};
          "Mod+WheelScrollUp" = {spawn-sh = "${smart-workspace} up";};
          "Mod+WheelScrollDown" = {spawn-sh = "${smart-workspace} down";};
          "Mod+Backspace" = {focus-workspace-previous = [];};
        })

      (mkIf (!cfg.binds.useSmartWorkspaceBinds) {
        "Mod+BracketLeft" = {focus-workspace-up = [];};
        "Mod+BracketRight" = {focus-workspace-down = [];};
        "Mod+WheelScrollUp" = {focus-workspace-up = [];};
        "Mod+WheelScrollDown" = {focus-workspace-down = [];};
        "Mod+Backspace" = {focus-workspace-previous = [];};
      })

      (mkWorkspaceBinds "Mod" "focus-workspace")
      (mkWorkspaceBinds "Mod+Shift" "move-column-to-workspace")

      (mkIf config.glace.tools.desktop.hyprpicker.enable {
        "Mod+B" = withProps {hotkey-overlay-title = "Pick Color";} {
          spawn-sh = ["hyprpicker -a"];
        };
      })

      (mkIf cfg.binds.defaultAudioBinds {
        "XF86AudioRaiseVolume" = withProps {
          hotkey-overlay-title = "Increase Volume";
          allow-when-locked = true;
        } {spawn-sh = ["wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1+"];};
        "XF86AudioLowerVolume" = withProps {
          hotkey-overlay-title = "Decrease Volume";
          allow-when-locked = true;
        } {spawn-sh = ["wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1-"];};
        "XF86AudioMute" = withProps {
          hotkey-overlay-title = "Toggle Mute";
          allow-when-locked = true;
        } {spawn-sh = ["wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"];};

        "Ctrl+XF86AudioRaiseVolume" = withProps {
          hotkey-overlay-title = "Increase Mic Volume";
          allow-when-locked = true;
        } {spawn-sh = ["wpctl" "set-volume" "@DEFAULT_AUDIO_SOURCE@" "0.1+"];};
        "Ctrl+XF86AudioLowerVolume" = withProps {
          hotkey-overlay-title = "Decrease Mic Volume";
          allow-when-locked = true;
        } {spawn-sh = ["wpctl" "set-volume" "@DEFAULT_AUDIO_SOURCE@" "0.1-"];};
        "Ctrl+XF86AudioMute" = withProps {
          hotkey-overlay-title = "Toggle Mic Mute";
          allow-when-locked = true;
        } {spawn-sh = ["wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle"];};
      })

      (mkIf cfg.binds.defaultBrightnessBinds {
        "XF86MonBrightnessUp" = withProps {
          hotkey-overlay-title = "Increase Brightness";
          allow-when-locked = true;
        } {spawn-sh = ["brightnessctl" "set" "10%+"];};
        "XF86MonBrightnessDown" = withProps {
          hotkey-overlay-title = "Decrease Brightness";
          allow-when-locked = true;
        } {spawn-sh = ["brightnessctl" "set" "10%-"];};
      })

      # Night Light Toggle
      (mkIf config.glace.desktop.addons.wlsunset.enable {
        "Mod+Shift+N" = withProps {hotkey-overlay-title = "Toggle Night Light";} {
          spawn-sh = ["systemctl --user is-active wlsunset.service && systemctl --user stop wlsunset.service || systemctl --user start wlsunset.service"];
        };
      })

      # Screenshots
      (mkIf (!config.glace.desktop.dank-material-shell.enable) {
        "Print" = withProps {hotkey-overlay-title = "Take Screenshot";} {
          spawn-sh = ["niri" "msg" "action" "screenshot"];
        };
      })

      # Application Shortcuts
      (mkIf (config.glace.apps.terminals.default != null) {
        "Mod+Return" = withProps {hotkey-overlay-title = "Open Terminal (tmux)";} {
          spawn = config.glace.apps.terminals.commands.withTmux;
        };

        "Mod+Shift+Return" = withProps {hotkey-overlay-title = "Open Terminal";} {
          spawn = config.glace.apps.terminals.commands.base;
        };
      })
    ];

    glace.cli.aliases = {
      kill-window = "kill -9 $(niri msg -j pick-window | jq -r '.pid')";
    };
  };
}
