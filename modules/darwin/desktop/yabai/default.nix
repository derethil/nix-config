{
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.desktop.yabai;

  # Generate workspace binds similar to Hyprland config
  mkWorkspaceBinds = mod: dispatcher:
    lib.concatMapStringsSep "\n" (i: "${mod} - ${
      if i == 10
      then "0"
      else toString i
    } : yabai -m ${dispatcher} ${toString i}") (lib.range 1 10);
in {
  options.glace.desktop.yabai = {
    enable = mkBoolOpt false "Whether or not to enable the Yabai window manager.";
  };

  config = mkIf cfg.enable {
    services.yabai = {
      enable = true;
      enableScriptingAddition = true;
      config = {
        # Focus follows mouse
        focus_follows_mouse = "on";
        mouse_follows_focus = "on";

        # Window management
        window_origin_display = "default";
        window_placement = "second_child";
        window_zoom_persist = "on";
        window_shadow = "on";
        window_animation_duration = 0.0;
        window_animation_frame_rate = 120;
        window_opacity_duration = 0.0;
        active_window_opacity = 1.0;
        normal_window_opacity = 0.90;
        window_opacity = "off";
        insert_feedback_color = "0xff7FB4CA";
        split_ratio = 0.50;
        split_type = "auto";
        auto_balance = "off";

        # Mouse
        mouse_modifier = "fn";
        mouse_action1 = "move";
        mouse_action2 = "resize";
        mouse_drop_action = "swap";

        # General space settings
        layout = "bsp";
        top_padding = 12;
        bottom_padding = 12;
        left_padding = 12;
        right_padding = 12;
        window_gap = 6;

        # Debug
        debug_output = "off";
      };
      extraConfig = ''
        # Create 5 spaces on startup
        for i in {2..5}; do
          yabai -m space --create
        done
      '';
    };

    services.skhd = {
      enable = true;
      skhdConfig = ''
        # Terminal shortcuts
        cmd - return : open -na "Alacritty" --args -e tmux new-session -As base
        cmd + shift - return : open -na "Alacritty"

        # Window management
        cmd - q : yabai -m window --close
        cmd - f : yabai -m window --toggle zoom-fullscreen
        cmd + shift - f : yabai -m window --toggle zoom-parent

        # Focus window
        cmd - h : yabai -m window --focus west
        cmd - j : yabai -m window --focus south
        cmd - k : yabai -m window --focus north
        cmd - l : yabai -m window --focus east

        # Move window
        cmd + shift - h : yabai -m window --warp west
        cmd + shift - j : yabai -m window --warp south
        cmd + shift - k : yabai -m window --warp north
        cmd + shift - l : yabai -m window --warp east

        # Resize window
        cmd + ctrl - h : yabai -m window --resize left:-256:0 || yabai -m window --resize right:-256:0
        cmd + ctrl - j : yabai -m window --resize bottom:0:256 || yabai -m window --resize top:0:256
        cmd + ctrl - k : yabai -m window --resize top:0:-256 || yabai -m window --resize bottom:0:-256
        cmd + ctrl - l : yabai -m window --resize right:256:0 || yabai -m window --resize left:256:0

        # Toggle window behaviors
        cmd - space : yabai -m window --focus next || yabai -m window --focus first
        cmd + shift - space : yabai -m window --toggle float --grid 4:4:1:1:2:2
        cmd + shift - p : yabai -m window --togle sticky

        # Window insertion point
        cmd + alt - h : yabai -m window --insert west
        cmd + alt - j : yabai -m window --insert south
        cmd + alt - k : yabai -m window --insert north
        cmd + alt - l : yabai -m window --insert east

        # Window stacking
        cmd + shift + alt - h : yabai -m window --stack west
        cmd + shift + alt - j : yabai -m window --stack south
        cmd + shift + alt - k : yabai -m window --stack north
        cmd + shift + alt - l : yabai -m window --stack east

        # Navigate stacked windows
        cmd - tab : yabai -m window --focus stack.next || yabai -m window --focus next
        cmd + shift - tab : yabai -m window --focus stack.prev || yabai -m window --focus prev

        # Reload yabai
        cmd + shift - r : launchctl kickstart -k "gui/''${UID}/homebrew.mxcl.yabai"

        # Workspace switching
        ${mkWorkspaceBinds "cmd" "space --focus"}
        cmd - [ : yabai -m space --focus prev || yabai -m space --focus last
        cmd - ]: yabai -m space --focus next || yabai -m space --focus first

        # Move to workspace (with focus)
        ${mkWorkspaceBinds "cmd + shift" "window --space"}
      '';
    };
  };
}
