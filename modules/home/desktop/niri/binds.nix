{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkMerge getExe;
  inherit (lib.strings) join;
  cfg = config.glace.desktop.niri;

  mkWorkspaceBinds' = mod: action: extraArgs:
    builtins.listToAttrs (map (i: let
      key =
        if i == 10
        then "0"
        else toString i;
    in {
      name = "${mod}+${key}";
      value =
        if extraArgs == null
        then {action.${action} = i;}
        else {action.${action} = i;} // extraArgs;
    }) (lib.range 1 10));

  mkWorkspaceBinds = key: action: mkWorkspaceBinds' key action null;

  action' = description: action: {
    hotkey-overlay.title = description;
    action = action;
  };

  mkAppKeybind = description: args: let
    command =
      if config.glace.desktop.uwsm.enable
      then ["uwsm-app" "--"] ++ args
      else args;
  in
    action' description (config.lib.niri.actions.spawn command);

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
    programs.niri.settings.binds = with config.lib.niri.actions;
      mkMerge [
        {
          # Exit Session
          "Mod+Shift+E" = action' "Exit Session" (
            if config.glace.desktop.uwsm.enable
            then spawn-sh "uwsm stop"
            else {quit.skip-confirmation = true;}
          );

          # Hotkey Overlay
          "Mod+Shift+Slash" = mkIf (!config.glace.desktop.dank-material-shell.enable) (
            action' "Show Hotkey Overlay" (spawn-sh "niri msg action show-hotkey-overlay")
          );

          # Window Commands
          "Mod+Q".action = close-window;
          "Mod+F".action = fullscreen-window;
          "Mod+Shift+F".action = toggle-windowed-fullscreen;

          # Quick Launcher
          "Mod+D".action = spawn-sh (getExe (mkMenu [
            {
              key = "t";
              desc = "Terminal";
              cmd = join " " config.glace.apps.terminals.commands.withTmux;
            }
            {
              key = "f";
              desc = "Firefox";
              cmd = "firefox";
            }
            {
              key = "m";
              desc = "Music";
              cmd = "spotify";
            }
            {
              key = "d";
              desc = "Discord";
              cmd = "vesktop";
            }
            {
              key = "c";
              desc = "Mattermost";
              cmd = "mattermost-desktop";
            }
            {
              key = "o";
              desc = "Obsidian";
              cmd = "obsidian";
            }
          ]));

          # Floating Windows
          "Mod+Space".action = switch-focus-between-floating-and-tiling;
          "Mod+Shift+Space".action = toggle-window-floating;
          "Mod+MouseForward".action = toggle-window-floating;

          # Focus Windows / Columns
          "Mod+Home".action = focus-column-first;
          "Mod+End".action = focus-column-last;
          "Mod+H".action = focus-column-left;
          "Mod+L".action = focus-column-right;
          "Mod+K".action = focus-window-up;
          "Mod+J".action = focus-window-down;

          # Move Windows / Columns within Workspace
          "Mod+Shift+Home".action = move-column-to-first;
          "Mod+Shift+End".action = move-column-to-last;
          "Mod+Shift+H".action = move-column-left;
          "Mod+Shift+L".action = move-column-right;
          "Mod+Shift+K".action = move-window-up;
          "Mod+Shift+J".action = move-window-down;

          "Mod+Ctrl+H".action = consume-or-expel-window-left;
          "Mod+Ctrl+L".action = consume-or-expel-window-right;

          # Resize Columns
          "Mod+S".action = toggle-column-tabbed-display;
          "Mod+R".action = spawn-sh (getExe (mkMenu [
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
          ]));

          # Switch Workspaces
          "Mod+Backspace".action = focus-workspace-previous;
          "Mod+BracketLeft".action = focus-workspace-up;
          "Mod+BracketRight".action = focus-workspace-down;
          "Mod+WheelScrollUp".action = focus-workspace-up;
          "Mod+WheelScrollDown".action = focus-workspace-down;

          # Overview
          "Alt+Tab".action = toggle-overview;
        }

        # Workspace Management
        (mkWorkspaceBinds "Mod" "focus-workspace")
        (mkWorkspaceBinds "Mod+Shift" "move-column-to-workspace")
        # (mkWorkspaceBinds' "Mod+Ctrl+Shift" "move-column-to-workspace" {focus = false;})

        # Color Picker
        (mkIf config.glace.tools.desktop.hyprpicker.enable {
          "Mod+B" = action' "Pick Color" (spawn-sh "hyprpicker -a");
        })

        # Audio Control
        (mkIf cfg.binds.defaultAudioBinds {
          "XF86AudioRaiseVolume" = {
            hotkey-overlay.title = "Increase Volume";
            action = spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+";
            allow-when-locked = true;
          };
          "XF86AudioLowerVolume" = {
            hotkey-overlay.title = "Decrease Volume";
            action = spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-";
            allow-when-locked = true;
          };
          "XF86AudioMute" = {
            hotkey-overlay.title = "Toggle Mute";
            action = spawn-sh "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
            allow-when-locked = true;
          };

          "Ctrl+XF86AudioRaiseVolume" = {
            hotkey-overlay.title = "Increase Mic Volume";
            action = spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 0.1+";
            allow-when-locked = true;
          };
          "Ctrl+XF86AudioLowerVolume" = {
            hotkey-overlay.title = "Decrease Mic Volume";
            action = spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 0.1-";
            allow-when-locked = true;
          };
          "Ctrl+XF86AudioMute" = {
            hotkey-overlay.title = "Toggle Mic Mute";
            action = spawn-sh "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
            allow-when-locked = true;
          };
        })

        # Screen Backlight Control
        (mkIf cfg.binds.defaultBrightnessBinds {
          "XF86MonBrightnessUp" = {
            hotkey-overlay.title = "Increase Brightness";
            action = spawn-sh "brightnessctl set 10%+";
            allow-when-locked = true;
          };
          "XF86MonBrightnessDown" = {
            hotkey-overlay.title = "Decrease Brightness";
            action = spawn-sh "brightnessctl set 10%-";
            allow-when-locked = true;
          };
        })

        # Night Light Toggle
        (mkIf config.glace.desktop.addons.wlsunset.enable {
          "Mod+Shift+N" = action' "Toggle Night Light" (spawn-sh "systemctl --user is-active wlsunset.service && systemctl --user stop wlsunset.service || systemctl --user start wlsunset.service");
        })

        # Screenshots
        (mkIf (!config.glace.desktop.dank-material-shell.enable) {
          "Print".action.screenshot = [];
        })

        # Application Shortcuts
        (mkIf (config.glace.apps.terminals.default != null) {
          "Mod+Return" =
            mkAppKeybind
            "Open Terminal (tmux)"
            config.glace.apps.terminals.commands.withTmux;

          "Mod+Shift+Return" =
            mkAppKeybind
            "Open Terminal"
            config.glace.apps.terminals.commands.base;
        })
      ];

    glace.cli.aliases = {
      kill-window = "kill -9 $(niri msg -j pick-window | jq -r '.pid')";
    };
  };
}
