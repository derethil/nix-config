{
  flake.modules.homeManager.noctalia-panel = {
    programs.noctalia.settings = {
      accessibility = {
        high_contrast = false;
        ui_scale = 1;
      };

      audio = {
        enable_overdrive = false;
        enable_sounds = false;
        notification_sound = "";
        sound_volume = 0.5;
        volume_change_sound = "";
      };

      backdrop = {
        blur_intensity = 0.5;
        enabled = true;
        tint_intensity = 0.30000001192092896;
      };

      bar = {
        default = {
          auto_hide = false;
          background_opacity = 1;
          border = "outline";
          border_width = 0;
          capsule = true;
          capsule_fill = "surface_variant";

          capsule_group = [
            {
              accordion = false;
              accordion_direction = "end";
              enabled = true;
              fill = "surface_variant";
              id = "ai_usage";

              members = [
                "codex_icon"
                "ai_usage_codex"
                "claude_icon"
                "ai_usage_claude"
              ];

              opacity = 1;
              padding = 8;
              radius = 8;
            }
            {
              accordion = false;
              accordion_direction = "end";
              enabled = true;
              fill = "surface_variant";
              id = "g1";

              members = [
                "network"
                "bluetooth"
                "volume"
              ];

              opacity = 1;
              padding = 8;
              radius = 8;
            }
            {
              accordion = false;
              accordion_direction = "end";
              enabled = true;
              fill = "surface_variant";
              id = "g2";

              members = [
                "clock"
                "date"
              ];

              opacity = 1;
              padding = 8;
              radius = 8;
            }
            {
              accordion = false;
              accordion_direction = "end";
              enabled = true;
              fill = "surface_variant";
              id = "g3";

              members = [
                "cpu"
                "sysmon"
                "ram"
              ];

              opacity = 1;
              padding = 8;
              radius = 8;
            }
            {
              accordion = false;
              accordion_direction = "end";
              enabled = true;
              fill = "surface_variant";
              id = "g4";

              members = [
                "privacy"
                "cast_window"
              ];

              opacity = 1;
              padding = 8;
              radius = 8;
            }
          ];

          capsule_opacity = 1;
          capsule_padding = 8;
          capsule_radius = 8;
          capsule_thickness = 0.7599999904632568;

          center = [
            "audio_visualizer"
            "group:g2"
            "weather"
            "bar"
          ];

          concave_edge_corners = true;
          contact_shadow = false;
          dead_zone = {};
          enabled = true;

          end = [
            "todo"
            "clipboard"
            "brightness"
            "battery"
            "notifications"
            "caffeine"
            "group:ai_usage"
            "group:g1"
            "help"
            "session"
          ];

          font_scale = 1;
          font_weight = 500;
          hover_highlight = true;
          layer = "top";
          margin_edge = 0;
          margin_ends = 0;
          margin_opposite_edge = 0;
          padding = 14;
          panel_overlap = 1;
          position = "left";
          radius = 12;
          radius_bottom_left = 12;
          radius_bottom_right = 12;
          radius_top_left = 12;
          radius_top_right = 12;
          reserve_space = true;
          scale = 1;
          shadow = true;
          show_on_workspace_switch = true;
          smart_auto_hide = false;

          start = [
            "launcher"
            "workspaces"
            "tray"
            "group:g4"
            "group:g3"
          ];

          thickness = 44;
          widget_spacing = 8;
        };

        order = [
          "default"
        ];
      };

      battery.warning_threshold = 10;

      brightness = {
        enable_ddcutil = false;
        ignore_mmids = [];
        minimum_brightness = 0;
        sync_all_monitors = true;
      };

      calendar = {
        account.calendars = {
          calendars = [];
          color = "primary";
          credential_source = "secret-service";
          name = "Vdir Calendars";
          password_file = "";
          path = "/home/derethil/.local/share/calendars";
          provider = "";
          server_url = "";
          type = "vdir";
          username = "";
        };

        enabled = true;
        event_date_format = "%A %e %B";
        event_time_format = "{:%I:%M %p}";
        refresh_minutes = 15;
      };

      config_version = 14;

      control_center = {
        calendar = {
          show_events_card = true;
          show_week_numbers = false;
        };

        hidden_tabs = [];

        shortcuts = [
          {
            type = "wifi";
          }
          {
            type = "bluetooth";
          }
          {
            type = "caffeine";
          }
          {
            type = "nightlight";
          }
          {
            type = "notification";
          }
          {
            type = "power_profile";
          }
        ];

        show_session_button = true;
        show_shortcut_labels = true;
        sidebar = "full";
        sidebar_section = "full";
        width = 700;
      };

      desktop_widgets = {
        enabled = true;

        grid = {
          cell_size = 16;
          major_interval = 4;
          visible = true;
        };

        schema_version = 2;
      };

      dock = {
        active_monitor_only = false;
        active_opacity = 1;
        active_scale = 1;
        auto_hide = false;
        background_opacity = 0.8799999952316284;
        border = "outline";
        border_width = 0;
        concave_edge_corners = true;
        cross_axis_padding = 8;
        enabled = true;
        icon_size = 48;
        inactive_opacity = 0.8500000238418579;
        inactive_scale = 0.8500000238418579;
        item_spacing = 6;
        launcher_custom_image = "";
        launcher_custom_image_colorize = false;
        launcher_icon = "grid-dots";
        launcher_position = "start";
        layer = "overlay";
        magnification = true;
        magnification_scale = 1.3000000044703484;
        main_axis_padding = 16;
        margin_edge = 0;
        margin_ends = 0;
        monitors = [];

        pinned = [
          "footclient"
          "firefox"
          "codex-desktop"
          "vesktop"
          "Mattermost.Desktop"
          "bruno"
          "obsidian"
          "steam"
          "org.prismlauncher.PrismLauncher"
          "com.stremio.Stremio"
          "spotify"
        ];

        position = "bottom";
        radius = 16;
        radius_bottom_left = 16;
        radius_bottom_right = 16;
        radius_top_left = 16;
        radius_top_right = 16;
        reserve_space = false;
        shadow = true;
        show_dots = true;
        show_instance_count = true;
        show_running = true;
        smart_auto_hide = true;
      };

      hooks = {
        battery_charging = [];
        battery_discharging = [];
        battery_percentage_changed = [];
        battery_plugged = [];
        bluetooth_disabled = [];
        bluetooth_enabled = [];
        colors_changed = [];
        logging_out = [];
        power_profile_changed = [];
        rebooting = [];
        session_locked = [];
        session_unlocked = [];
        shutting_down = [];
        started = [];
        theme_mode_changed = [];
        wallpaper_changed = [];
        wifi_disabled = [];
        wifi_enabled = [];
      };

      hot_corners = {
        bottom_left = {
          action = "none";
          command = "";
        };

        bottom_right = {
          action = "none";
          command = "";
        };

        delay_ms = 0;
        enabled = false;

        top_left = {
          action = "none";
          command = "";
        };

        top_right = {
          action = "none";
          command = "";
        };
      };

      idle = {
        behavior = {
          lock = {
            action = "lock";
            command = "";
            enabled = true;
            locked_timeout = 0;
            resume_command = "";
            timeout = 600;
          };

          lock-and-suspend = {
            action = "lock_and_suspend";
            command = "";
            enabled = true;
            locked_timeout = 0;
            resume_command = "";
            timeout = 900;
          };

          screen-off = {
            action = "screen_off";
            command = "";
            enabled = true;
            locked_timeout = 0;
            resume_command = "";
            timeout = 660;
          };
        };

        behavior_order = [
          "lock"
          "screen-off"
          "lock-and-suspend"
        ];

        pre_action_fade_seconds = 2;
      };

      keybinds = {
        cancel = [
          "Escape"
        ];

        copy = [
          "Ctrl+c"
        ];

        delete = [
          "Delete"
        ];

        down = [
          "Down"
        ];

        left = [
          "Left"
        ];

        right = [
          "Right"
        ];

        save = [
          "Ctrl+s"
        ];

        tab_next = [
          "Tab"
        ];

        tab_previous = [
          "Shift+ISO_Left_Tab"
        ];

        up = [
          "Up"
        ];

        validate = [
          "Return"
          "KP_Enter"
          "space"
        ];
      };

      location = {
        address = "";
        auto_locate = true;
        custom_schedule = false;
        sunrise = "";
        sunset = "";
      };

      lockscreen = {
        allow_empty_password = false;
        blur_intensity = 0.5999999865889549;
        blurred_desktop = true;
        enabled = true;
        fingerprint = true;
        lock_before_suspend = true;
        monitors = [];
        tint_intensity = 0.3999999910593033;
        wallpaper = "";
      };

      lockscreen_widgets = {
        enabled = true;

        grid = {
          cell_size = 16;
          major_interval = 4;
          visible = true;
        };

        schema_version = 2;

        widget = {
          "lockscreen-login-box@DP-2" = {
            box_height = 196;
            box_width = 810;
            cx = 1720;
            cy = 1258;
            enabled = true;
            output = "DP-2";
            placement_height = 1440;
            placement_width = 3440;
            rotation = 0;

            settings = {
              background_color = "surface_variant";
              background_opacity = 0.88;
              background_radius = 12;
              center_password_text = false;
              input_opacity = 1;
              input_radius = 6;
              layout = "regular";
              show_caps_lock = true;
              show_keyboard_layout = true;
              show_login_button = true;
              show_media = true;
              show_session_buttons = true;
              show_unlock_hint = true;
              show_weather = true;
            };

            type = "login_box";
          };

          lockscreen-widget-0000000000000003 = {
            box_height = 144;
            box_width = 832;
            cx = 1704;
            cy = 312;
            enabled = true;
            output = "DP-2";
            placement_height = 1440;
            placement_width = 3440;
            rotation = 0;

            settings = {
              background = false;
              font_family = "Inter Display Black";
              format = "{:%I:%M %p}";
              shadow = true;
            };

            type = "clock";
          };

          lockscreen-widget-0000000000000004 = {
            box_height = 144;
            box_width = 192;
            cx = 1411;
            cy = 576;
            enabled = true;
            output = "DP-2";
            placement_height = 1440;
            placement_width = 3440;
            rotation = 0;
            settings.background = true;
            type = "fancy_audio_visualizer";
          };

          lockscreen-widget-0000000000000007 = {
            box_height = 432;
            box_width = 624;
            cx = 1832;
            cy = 720;
            enabled = true;
            output = "DP-2";
            placement_height = 1440;
            placement_width = 3440;
            rotation = 0;

            settings = {
              background = true;
              show_events = true;
            };

            type = "calendar";
          };

          lockscreen-widget-0000000000000008 = {
            box_height = 272;
            box_width = 192;
            cx = 1411;
            cy = 800;
            enabled = true;
            output = "DP-2";
            placement_height = 1440;
            placement_width = 3440;
            rotation = 0;
            settings.layout = "vertical";
            type = "media_player";
          };
        };

        widget_order = [
          "lockscreen-widget-0000000000000004"
          "lockscreen-login-box@DP-2"
          "lockscreen-widget-0000000000000003"
          "lockscreen-widget-0000000000000007"
          "lockscreen-widget-0000000000000008"
        ];
      };

      nightlight = {
        enabled = false;
        force = false;
        temperature_day = 6500;
        temperature_night = 4000;
      };

      notification = {
        background_opacity = 0.9700000286102295;
        border = true;
        collapse_on_dismiss = true;
        enable_daemon = true;
        history_retention_hours = 0;
        keep_dismissed_in_history = true;
        layer = "overlay";
        max_visible = 0;
        monitors = [];
        offset_x = 20;
        offset_y = 8;
        position = "top_center";
        scale = 1;
        show_actions = true;
        show_app_name = true;
      };

      osd = {
        background_opacity = 0.9700000286102295;
        border = true;
        enabled = true;

        kinds = {
          bluetooth = true;
          brightness = true;
          caffeine = true;
          dnd = true;
          keyboard_backlight = true;
          keyboard_layout = true;
          lock_keys = true;
          media = true;
          nightlight = true;
          power_profile = true;
          privacy = true;
          volume = true;
          volume_input = true;
          volume_output = true;
          wifi = true;
        };

        monitors = [];
        offset_x = 20;
        offset_y = 8;
        orientation = "horizontal";
        position = "bottom_center";
        position_vertical = "center_right";
        scale = 1.1000000089406967;
      };

      shell = {
        animation = {
          enabled = true;
          speed = 1.2500000186264515;
        };

        app_icon_colorize = false;
        avatar_path = "";
        button_borders = true;
        card_borders = true;
        clipboard_auto_paste = "auto";
        clipboard_confirm_clear_history = true;
        clipboard_enabled = true;
        clipboard_history_max_entries = 100;
        clipboard_image_action_command = "";
        clipboard_keep_from_closed_apps = true;
        corner_radius_scale = 1;
        date_format = "%A, %x";
        disable_mipmaps = false;
        external_ip_enabled = false;
        font_family = "Inter Medium";
        greeter_sync.auto_sync = true;
        input_borders = true;
        keyboard_layout = {};
        launch_apps_as_systemd_services = true;
        launch_apps_custom_command = "";

        launcher = {
          app_grid = false;
          auto_paste = "auto";
          categories = true;
          compact = false;
          dmenu = {};
          fetch_exchange_rates = true;

          panels.ignored = [
            "polkit"
            "setup-wizard"
            "test"
            "launcher"
          ];

          pinned = [
            "firefox"
          ];

          provider_prefix = "/";
          show_app_actions = true;
          show_app_origin_indicator = true;
          show_icons = true;
          sort_by_usage = true;
        };

        mpris.blacklist = [];
        niri_overview_type_to_launch_enabled = true;
        offline_mode = false;

        panel = {
          borders = true;
          clipboard_placement = "floating";
          clipboard_position = "center";
          control_center_placement = "attached";
          control_center_position = "auto";
          floating_layer = "overlay";
          floating_offset = 8;
          launcher_placement = "floating";
          launcher_position = "center";
          list_item_background = false;
          open_near_click_clipboard = false;
          open_near_click_control_center = true;
          open_near_click_launcher = false;
          open_near_click_session = true;
          open_near_click_wallpaper = false;
          polkit_placement = "floating";
          polkit_position = "center";
          session_placement = "attached";
          session_position = "center";
          shadow = true;
          transparency_mode = "solid";
          wallpaper_placement = "attached";
          wallpaper_position = "auto";
        };

        password_style = "random";
        polkit_agent = true;
        popup_borders = true;
        popup_shadows = true;

        privacy = {
          cam_filter_regex = "";
          mic_filter_regex = "";
          screen_filter_regex = "";
        };

        screen_corners = {
          enabled = true;
          size = 32;
        };

        screen_time_enabled = true;

        screenshot = {
          annotate = false;
          close_on_copy = true;
          close_on_save = true;
          confirm_region = true;
          copy_to_clipboard = true;
          directory = "/home/derethil/Pictures/screenshots";
          filename_pattern = "";
          freeze_screen = true;
          pipe_command = "";
          pipe_to_command = true;
          remember_last_region = true;
          save_to_file = true;
          show_cursor = true;
          skip_annotate_on_copy_save = false;
        };

        session = {
          actions = [
            {
              action = "lock";
              command = "";
              countdown_seconds = 0;
              enabled = true;
              glyph = "";
              label = "";
              shortcut = "1";
              variant = "default";
            }
            {
              action = "logout";
              command = "";
              countdown_seconds = 0;
              enabled = true;
              glyph = "";
              label = "";
              shortcut = "2";
              variant = "default";
            }
            {
              action = "lock_and_suspend";
              command = "";
              countdown_seconds = 0;
              enabled = true;
              glyph = "";
              label = "";
              shortcut = "3";
              variant = "default";
            }
            {
              action = "reboot";
              command = "";
              countdown_seconds = 0;
              enabled = true;
              glyph = "";
              label = "";
              shortcut = "4";
              variant = "default";
            }
            {
              action = "shutdown";
              command = "";
              countdown_seconds = 0;
              enabled = true;
              glyph = "";
              label = "";
              shortcut = "5";
              variant = "destructive";
            }
          ];

          grid = false;
          grid_columns = 5;
          power = {};
          show_shortcuts = true;
        };

        settings_show_advanced = true;
        settings_window_translucent = false;
        setup_wizard_enabled = true;

        shadow = {
          alpha = 0.550000011920929;
          direction = "down";
        };

        shared_gl_context = true;
        show_location = true;
        telemetry_enabled = false;
        time_format = "{:%I:%M %p}";
        umbriel_overview_type_to_launch_enabled = false;
        window_switcher.mru = false;
      };

      storage = {
        key_file = "";
        key_source = "secret-service";
      };

      system.monitor = {
        cpu_freq_activity_threshold = 2.5;
        cpu_freq_critical_threshold = 4.5;
        cpu_poll_seconds = 2;
        cpu_temp_activity_threshold = 60;
        cpu_temp_critical_threshold = 85;
        cpu_temp_sensor_path = "";
        cpu_usage_activity_threshold = 50;
        cpu_usage_critical_threshold = 90;
        disk_free_activity_threshold = 80;
        disk_free_critical_threshold = 95;
        disk_free_pct_activity_threshold = 80;
        disk_free_pct_critical_threshold = 95;
        disk_poll_seconds = 10;
        disk_used_activity_threshold = 80;
        disk_used_critical_threshold = 95;
        disk_used_pct_activity_threshold = 80;
        disk_used_pct_critical_threshold = 95;
        enabled = true;
        gpu_poll_seconds = 5;
        gpu_temp_activity_threshold = 60;
        gpu_temp_critical_threshold = 85;
        gpu_usage_activity_threshold = 50;
        gpu_usage_critical_threshold = 95;
        gpu_vram_activity_threshold = 50;
        gpu_vram_critical_threshold = 90;
        memory_poll_seconds = 2;
        net_rx_activity_threshold = 1;
        net_rx_critical_threshold = 50;
        net_tx_activity_threshold = 1;
        net_tx_critical_threshold = 50;
        network_poll_seconds = 3;
        ram_pct_activity_threshold = 60;
        ram_pct_critical_threshold = 90;
        swap_pct_activity_threshold = 20;
        swap_pct_critical_threshold = 80;
      };

      theme = {
        builtin = "Kanagawa";
        community_palette = "Kanagawa Dragon";
        custom_palette = "";
        mode = "dark";
        pure_black_dark = false;
        shell_mode = "follow";
        source = "community";

        templates = {
          builtin_ids = [];
          community_ids = [];
          enable_builtin_templates = false;
          enable_community_templates = true;
        };

        wallpaper_scheme = "m3-content";
      };

      wallpaper = {
        automation = {
          enabled = false;
          interval_seconds = 1800;
          order = "random";
          recursive = false;
        };

        default.path = "/home/derethil/Pictures/wallpapers/fuji-bird.jpeg";
        directory = "/home/derethil/Pictures/wallpapers";
        directory_dark = "";
        directory_light = "";
        edge_smoothness = 0.30000001192092896;
        enabled = true;
        fill_color = "";
        fill_mode = "crop";
        last.path = "/home/derethil/Pictures/wallpapers/fuji-bird.jpeg";
        monitors.DP-2.path = "/home/derethil/Pictures/wallpapers/fuji-bird.jpeg";
        per_monitor_directories = false;

        transition = [
          "disc"
        ];

        transition_duration = 1500;
        transition_on_startup = true;
      };

      weather = {
        effects = true;
        enabled = true;
        refresh_minutes = 30;
        unit = "imperial";
      };

      widget = {
        active_window = {
          icon_size = 14;
          max_length = 260;
          min_length = 80;
          title_scroll = "none";
          type = "active_window";
        };

        ai_usage_claude = {
          account = "";
          extras = "none";
          provider_limit = 1;
          show_glyph = false;
          show_value = true;
          type = "felipeartur/ai-usagebar:bar";
          vendor = "anthropic";
          visualization = "none";
        };

        ai_usage_codex = {
          account = "";
          extras = "none";
          provider_limit = 1;
          show_glyph = false;
          show_value = true;
          type = "felipeartur/ai-usagebar:bar";
          vendor = "openai";
          visualization = "none";
        };

        audio_visualizer = {
          actions = {
            back = "media previous";
            forward = "media next";
            left = "panel-toggle control-center media";
            right = "media toggle";
            scroll_down = "media previous";
            scroll_up = "media next";
          };

          show_when_idle = true;
          type = "audio_visualizer";
        };

        bar.type = "azokyen/spotify-media:bar";

        cast_window = {
          actions.left = "exec bash -c 'niri msg action set-dynamic-cast-window --id $(niri msg --json pick-window | jq -r .id)'";
          glyph = "cast";
          tooltip = "Cast Window";
          type = "custom_button";
        };

        claude_icon = {
          glyph = "asterisk-simple";
          tooltip = "Claude";
          type = "custom_button";
        };

        clock = {
          actions = {
            left = "panel-toggle control-center";
            right = "panel-toggle control-center calendar";
          };

          font_family = "GeistMono NF";
          format = "{:%I:%M}";
          tooltip_format = "{:%I:%M %p on %A, %B %-d}";
          type = "clock";
        };

        codex_icon = {
          glyph = "brand-openai";
          tooltip = "Codex";
          type = "custom_button";
        };

        cpu = {
          label_show_units = false;
          stat = "cpu_temp";
          type = "sysmon";
        };

        date = {
          color = "primary";
          font_family = "GeistMono NF";
          format = "{:%m %d}";
          type = "clock";
        };

        help = {
          actions.left = "panel-toggle kenn/keybind-cheatsheet:cheatsheet";
          glyph = "help";
          tooltip = "Open Help";
          type = "custom_button";
        };

        input_volume = {
          device = "input";
          type = "volume";
        };

        keyboard_layout = {
          hide_when_single_layout = false;
          type = "keyboard_layout";
        };

        launcher = {
          glyph = "grid-dots";
          type = "launcher";
        };

        lock_keys = {
          display = "short";
          hide_when_off = false;
          show_caps_lock = true;
          show_num_lock = true;
          show_scroll_lock = false;
          type = "lock_keys";
        };

        media = {
          art_size = 16;
          max_length = 220;
          min_length = 80;
          title_scroll = "none";
          type = "media";
        };

        network = {
          show_label = false;
          type = "network";
        };

        network_rx = {
          stat = "net_rx";
          type = "sysmon";
        };

        network_tx = {
          stat = "net_tx";
          type = "sysmon";
        };

        output_volume = {
          device = "output";
          type = "volume";
        };

        ram = {
          label_show_units = false;
          stat = "ram_pct";
          type = "sysmon";
        };

        spacer = {
          interactive = false;
          type = "spacer";
        };

        sysmon = {
          glyph = "gpu-usage";
          label_show_units = false;
          stat = "gpu_temp";
          type = "sysmon";
        };

        temp = {
          stat = "cpu_temp";
          type = "sysmon";
        };

        todo.type = "nightwatch75/todo:todo";

        tray = {
          enabled = false;
          type = "tray";
        };

        volume = {
          show_label = false;
          type = "volume";
        };

        weather = {
          font_scale = 0.95;
          type = "weather";
        };

        workspaces = {
          font_family = "Inter ExtraBold";
          hide_when_empty = false;
          show_labels = false;
          type = "workspaces";
        };
      };
    };
  };
}
