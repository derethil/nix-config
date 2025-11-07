{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf getExe flatten optionals;
  cfg = config.glace.desktop.hyprland;
  relativeworkspace = getExe pkgs.inputs.rust-system-scripts.relativeworkspace;

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
          # Exit Session
          "$mod Shift, E, exec, uwsm stop"

          # Color Picker
          (optionals config.glace.tools.desktop.hyprpicker.enable [
            "$mod, B, exec, shader=$(hyprshade current) ; hyprshade off ; hyprpicker -a ; hyprshade on \"$${shader}\""
          ])

          # Audio Control
          (optionals cfg.binds.defaultAudioBinds [
            ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 10%+"
            ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 10%-"
            ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"

            "CONTROL, XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 10%+"
            "CONTROL, XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 10%-"
            "CONTROL, XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
          ])

          # Screen Backlight Control
          (optionals cfg.binds.defaultBrightnessBinds [
            ", XF86MonBrightnessUp, exec, brightnessctl set 10%+"
            ", XF86MonBrightnessDown, exec, brightnessctl set 10%-"
          ])

          # Screenshots
          (optionals config.glace.tools.desktop.hyprshot.enable [
            ", Print, exec, shader=$(hyprshade current) ; hyprshade off ; hyprshot -m region --clipboard-only ; hyprshade on \"$${shader}\""
            "SHIFT, Print, exec, shader=$(hyprshade current) ; hyprshade off ; hyprshot -m region -o ~/Pictures/screenshots/ ; hyprshade on \"$${shader}\""
          ])

          # Application Shortcuts
          (optionals config.glace.apps.foot.enable [
            "$mod, RETURN, exec, ${pkgs.foot}/bin/footclient tmux new-session -As base"
            "$mod SHIFT, RETURN, exec, ${pkgs.foot}/bin/footclient"
            "$mod SHIFT CONTROL, RETURN, exec, ${pkgs.foot}/bin/foot"
          ])
          (optionals (!config.glace.apps.foot.enable && config.glace.apps.alacritty.enable) [
            "$mod, RETURN, exec, alacritty -e 'tmux new-session -As base'"
            "$mod SHIFT, RETURN, exec, alacritty"
          ])

          # Window Commands
          "$mod, Q, killactive"
          "$mod, F, fullscreen"
          "$mod SHIFT, F, fullscreenstate, -1, 2"

          # Floating Windows
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
          "$mod, mouse_up, exec, ${relativeworkspace} next"
          "$mod, mouse_down, exec, ${relativeworkspace} previous"

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
        ];

        bindm = [
          "$mod, mouse:272, movewindow"
          "$mod, mouse:273, resizewindow"
        ];

        gesture = [
          "3, vertical, workspace"
          "3, pinchout, fullscreen"
        ];
      };
    };
  };
}
