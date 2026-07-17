{
  flake.modules.darwin.paneru = {
    services.paneru.settings = {
      options = {
        focus_follows_mouse = true;
        mouse_follows_focus = true;
        animation_speed = 35;
        auto_center = false;
        sliver_height = 1.0;
        sliver_width = 5;
        window_resize_cycle = true;
        disable_native_tabs = false;
        insert_windows_mid_strip = false;
        reap_empty_workspaces = false;
        virtual_workspace_animations = false;
        preset_column_widths = [0.33 0.5 0.66 1.0];
        window_hidden_ratio = 0.0;
      };

      padding = {
        top = 1;
        bottom = 2;
        left = 2;
        right = 2;
      };

      swipe = {
        sensitivity = 0.35;
        deceleration = 4.0;
        continuous = true;

        gesture = {
          fingers_count = 3;
          direction = "Natural";
          vertical = true;
        };

        scroll = {
          modifier = "alt";
        };
      };

      decorations = {
        workspace_menu_status = true;
        workspace_popup_status = true;

        active.border = {
          enabled = true;
          color = "#d4be98";
          opacity = 1.0;
          width = 1.0;
          radius = "auto";
        };
      };
    };
  };
}
