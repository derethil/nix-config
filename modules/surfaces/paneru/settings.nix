{
  flake.modules.darwin.paneru = {
    services.paneru.settings = {
      options = {
        animation_speed = 35;
        auto_center = false;
        disable_native_tabs = false;
        focus_follows_mouse = true;
        insert_windows_mid_strip = false;
        mouse_follows_focus = true;
        preset_column_widths = [0.33 0.5 0.66 1.0];
        reap_empty_workspaces = false;
        sliver_height = 1.0;
        sliver_width = 5;
        virtual_workspace_animations = false;
        window_hidden_ratio = 0.0;
        window_resize_cycle = true;
      };

      decorations = {
        active.border = {
          color = "#d4be98";
          enabled = true;
          opacity = 1.0;
          radius = "auto";
          width = 1.0;
        };

        workspace_menu_status = true;
        workspace_popup_status = true;
      };

      padding = {
        bottom = 2;
        left = 2;
        right = 2;
        top = 1;
      };

      swipe = {
        continuous = true;
        deceleration = 4.0;

        gesture = {
          direction = "Natural";
          fingers_count = 3;
          vertical = true;
        };

        scroll.modifier = "alt";
        sensitivity = 0.35;
      };
    };
  };
}
