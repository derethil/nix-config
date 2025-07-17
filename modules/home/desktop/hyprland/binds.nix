{
  lib,
  config,
  inputs,
  pkgs,
  ...
}:
with lib; let
  cfg = config.desktop.hyprland;
  relativeworkspace = getExe inputs.rust-system-scripts.packages.${pkgs.system}.relativeworkspace;

  mkWorkspaceBinds = mod: dispatcher:
    map (i: "${mod}, ${
      if i == 10
      then "0"
      else toString i
    }, ${dispatcher}, ${toString i}") (lib.range 1 10);
in {
  config = mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      settings = {
        "$mod" = "SUPER";
        "$resizeAmount" = "256";

        bind = flatten [
          # Color Picker
          "$mod, C, exec, shader=$(hyprshade current) ; hyprshade off ; hyprpicker -a ; hyprshade on \"$${shader}\""

          # Exit Session
          "$mod, End, exec, uwsm stop"

          # Pulse (Command Palette)
          "$mod, Slash, exec, astal toggle pulse"

          # Audio Control
          ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 10%+"
          ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 10%-"
          ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"

          "CONTROL, XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 10%+"
          "CONTROL, XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 10%-"
          "CONTROL, XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"

          # Screen Backlight Control
          ", XF86MonBrightnessUp, exec, brightnessctl set 10%+"
          ", XF86MonBrightnessDown, exec, brightnessctl set 10%-"

          # Media Control
          ", XF86AudioStop, exec, astal-mpris stop"
          ", XF86AudioPause, exec, astal-mpris play-pause"
          ", XF86AudioNext, exec, astal-mpris next"
          ", XF86AudioPrev, exec, astal-mpris previous"

          # Screenshots
          ", Print, exec, shader=$(hyprshade current) ; hyprshade off ; hyprshot -m region --clipboard-only ; hyprshade on \"$${shader}\""
          "SHIFT, Print, exec, shader=$(hyprshade current) ; hyprshade off ; hyprshot -m region -o ~/Pictures/Screenshots/ ; hyprshade on \"$${shader}\""

          # Application Shortcuts
          "$mod, RETURN, exec, footclient tmux new-session -As base"
          "$mod SHIFT, RETURN, exec, footclient"
          "$mod SHIFT CONTROL, RETURN, exec, foot"

          # Window Commands
          "$mod, Q, killactive"
          "$mod SHIFT, R, exec, wofi  --show drun"
          "$mod, F, fullscreen"
          "$mod SHIFT, F, fullscreenstate, -1, 2"

          # Manage floating windows
          "$mod, mouse:276, pin"
          "$mod, mouse:275, togglefloating"

          "$mod, Space, cyclenext"
          "$mod Shift, Space, togglefloating"

          # Move focus
          "$mod, H, movefocus, l"
          "$mod, L, movefocus, r"
          "$mod, K, movefocus, u"
          "$mod, J, movefocus, d"

          # Switch workspaces
          "$mod, backslash, workspace, previous_per_monitor"
          "$mod, bracketright, exec, ${relativeworkspace} next"
          "$mod, bracketleft, exec, ${relativeworkspace} previous"

          # Workspace management
          (mkWorkspaceBinds "$mod" "workspace")
          (mkWorkspaceBinds "$mod SHIFT" "movetoworkspace")
          (mkWorkspaceBinds "$mod SHIFT CTRL" "movetoworkspacesilent")

          # Move active window within the current workspace
          "$mod SHIFT, H, movewindow, l"
          "$mod SHIFT, L, movewindow, r"
          "$mod SHIFT, K, movewindow, u"
          "$mod SHIFT, J, movewindow, d"

          # Resize active window
          "$mod CTRL, H, resizeactive, -$resizeAmount 0"
          "$mod CTRL, L, resizeactive, $resizeAmount 0"
          "$mod CTRL, K, resizeactive, 0 -$resizeAmount"
          "$mod CTRL, J, resizeactive, 0 $resizeAmount"

          # Scroll through existing workspaces
          "$mod, mouse_up, exec, ~/.local/bin/scrollworkspace next"
          "$mod, mouse_down, exec, ~/.local/bin/scrollworkspace previous"

          # Reload astal
          "CTRL SHIFT, R, exec, astal -q; ags run --directory ~/.config/astal"

          # DPMS
          "$mod, P, exec, hyprctl dispatch dpms on"
        ];

        bindm = [
          "$mod, mouse:272, movewindow"
          "$mod, mouse:273, resizewindow"
        ];
      };
    };
  };
}
