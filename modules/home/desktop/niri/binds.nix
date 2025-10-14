{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkMerge getExe getExe' flatten;
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
in {
  config = mkIf cfg.enable {
    programs.niri.settings.binds = with config.lib.niri.actions;
      mkMerge [
        {
          # Exit Session
          "Mod+Shift+E" = action' "Exit Session" (spawn-sh "uwsm stop");

          # Hotkey Overlay
          "Mod+Shift+Slash" = action' "Show Hotkey Overlay" (spawn-sh "niri msg action show-hotkey-overlay");

          # Window Commands
          "Mod+Q".action = close-window;
          "Mod+F".action = fullscreen-window;
          "Mod+Ctrl+F".action = expand-column-to-available-width;
          "Mod+Shift+F".action = toggle-windowed-fullscreen;

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
          "Mod+R".action = switch-preset-column-width;
          "Mod+Shift+R".action = switch-preset-window-width-back;
          "Mod+S".action = toggle-column-tabbed-display;

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
        (mkIf config.glace.tools.hyprpicker.enable {
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

        # Screenshots
        (mkIf ((!cfg.screenshots.builtin) && config.glace.tools.hyprshot.enable) {
          "Print" = action' "Screenshot Region" (spawn-sh "hyprshot -m region --clipboard-only");
          "Shift+Print" = action' "Screenshot Region to File" (spawn-sh "hyprshot -m region -o ${cfg.screenshots.path}");
        })

        (mkIf (cfg.screenshots.builtin) {
          "Print".action = screenshot;
          "Ctrl+Print".action = screenshot-window {write-to-disk = false;};
        })

        # Application Shortcuts
        (mkIf config.glace.apps.foot.enable {
          "Mod+Return" =
            action'
            "Open Terminal (tmux)"
            (spawn (flatten ["${getExe' pkgs.foot "footclient"}" (getExe pkgs.tmux) "new-session" "-As" "base"]));

          "Mod+Shift+Return" =
            action'
            "Open Terminal"
            (spawn ["${getExe' pkgs.foot "footclient"}"]);

          "Mod+Ctrl+Shift+Return" =
            action'
            "Open Terminal (server)"
            (spawn ["${getExe pkgs.foot}"]);
        })
        (mkIf (!config.glace.apps.foot.enable && config.glace.apps.alacritty.enable) {
          "Mod+Return" =
            action'
            "Open Terminal (tmux)"
            (spawn (flatten ["${getExe pkgs.alacritty}" "-e" (getExe pkgs.tmux) "new-session" "-As" "base"]));

          "Mod+Shift+Return" =
            action'
            "Open Terminal" (spawn ["${getExe pkgs.alacritty}"]);
        })
      ];
  };
}
