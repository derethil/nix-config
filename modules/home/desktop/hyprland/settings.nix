{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
with internal; let
  cfg = config.desktop.hyprland;
  gap = toString cfg.gap;
in {
  config = mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      settings = {
        exec-once = [
          "ags run --directory ~/.config/astal"
          "hyprctl dispatch workspace 1"
          "${pkgs.internal.import-env-tmux}/bin/import-env-tmux tmux HYPRLAND_CMD HYPRLAND_INSTANCE_SIGNATURE"
        ];
        general = {
          border_size = 2;
          # TODO: dynamic gap calculation from ags bar
          gaps_out = "${gap}, ${gap}, ${gap}, 83";
          gaps_in = 5;
          "col.active_border" = "rgba(7FB4CAee) rgba(98BB9Cee) 45deg";
          "col.inactive_border" = "rgba(727169aa)";
          layout = "master";
          resize_on_border = true;
          allow_tearing = false;
          no_focus_fallback = true;
        };

        master = {
          new_status = "slave";
          orientation = "left";
          mfact = 0.5;
        };

        decoration = {
          rounding = 8;

          shadow = {
            enabled = true;
            range = 48;
            render_power = 4;
            offset = "24 16";
            color = "rgba(1a1a1a00)";
            scale = 0.97;
          };

          blur = {
            enabled = true;
            xray = true;
            size = 7;
            passes = 4;
            noise = 0.01;
            brightness = 1.0;
            vibrancy = 0.2;
            vibrancy_darkness = 0.5;
            contrast = 1.1;
          };
        };

        animations = {
          enabled = true;

          bezier = [
            "overshot, 0.05, 0.9, 0.1, 1.15"
            "easeInOutExpo, 0.87, 0, 0.13, 1"
            "md3_standard, 0.2, 0, 0, 1"
            "md3_decel, 0.05, 0.7, 0.1, 1"
            "md3_accel, 0.3, 0, 0.8, 0.15"
            "menu_decel, 0.1, 1, 0, 1"
            "menu_accel, 0.38, 0.04, 1, 0.07"
          ];

          animation = [
            "windows, 1, 3, md3_decel, popin 60%"
            "windowsIn, 1, 3, md3_decel, slide"
            "windowsOut, 1, 3, md3_accel, slide"
            "layersIn, 1, 3, menu_decel, slide"
            "layersOut, 1, 2, menu_accel"
            "fadeLayersIn, 1, 2, menu_decel"
            "fadeLayersOut, 1, 1.5, menu_accel"
            "workspaces, 1, 6, menu_decel, slidevert"
          ];
        };

        input = {
          follow_mouse = 1;
          sensitivity = 0;

          touchpad = {
            disable_while_typing = true;
            natural_scroll = true;
            "tap-and-drag" = 1;
          };
        };

        gestures = {
          workspace_swipe = true;
          workspace_swipe_touch = true;
        };

        group = {
          groupbar = {
            font_size = 14;
            height = 8;
            render_titles = false;
          };
        };

        misc = {
          font_family = "Geist Mono Bold";
          disable_hyprland_logo = true;
          mouse_move_enables_dpms = true;
          key_press_enables_dpms = true;
          enable_swallow = true;
          swallow_regex = "^(footclient|GDLauncher)$";
          focus_on_activate = true;
          animate_manual_resizes = true;
          enable_anr_dialog = false;
        };

        binds = {
          allow_workspace_cycles = true;
          scroll_event_delay = 0;
          workspace_back_and_forth = true;
        };

        render = {
          direct_scanout = false;
        };

        cursor = {
          zoom_factor = 1.0;
          no_hardware_cursors = true;
        };

        debug = {
          colored_stdout_logs = true;
          disable_logs = false;
        };
      };
    };
  };
}
