{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.glace.desktop.niri;

  mkNumberedWorkspaces = count:
    builtins.listToAttrs (map (i: {
      name = toString i;
      value = {
        name = toString i;
      };
    }) (lib.range 1 count));
in {
  config = mkIf cfg.enable {
    programs.niri.settings = {
      workspaces = mkNumberedWorkspaces 5;

      switch-events = mkIf (cfg.events.defaultLidEvents) {
        lid-close.action.spawn = ["systemctl" "suspend"];
      };

      screenshot-path = "${cfg.screenshots.path}/%Y-%m-%d_%H-%M-%S.png";

      hotkey-overlay = {
        hide-not-bound = true;
        skip-at-startup = true;
      };

      prefer-no-csd = true;

      input = {
        focus-follows-mouse.enable = true;

        mouse = {
          accel-speed = 0.3;
          accel-profile = "flat";
          natural-scroll = false;
        };

        touchpad = {
          middle-emulation = true;
          click-method = "clickfinger";
          tap = true;
          tap-button-map = "left-right-middle";

          accel-profile = "adaptive";

          disabled-on-external-mouse = true;
          drag = true;
          dwt = true;

          natural-scroll = true;
        };

        power-key-handling.enable = false;

        warp-mouse-to-focus = {
          enable = true;
          mode = "center-xy";
        };

        workspace-auto-back-and-forth = true;
      };

      clipboard = {
        disable-primary = true;
      };

      cursor = {
        hide-when-typing = true;
        size = config.glace.desktop.addons.gtk.cursor.size;
        theme = config.glace.desktop.addons.gtk.cursor.name;
      };

      layout = {
        border = {
          enable = true;
          width = 2;
          active.color = "#FFB59B";
          inactive.color = "#322824";
          urgent.color = "#FFD59B";
        };

        focus-ring = {
          enable = false;
        };

        insert-hint = {
          enable = true;
          display.color = "#A79087";
        };

        preset-column-widths = [
          {proportion = 1. / 3.;}
          {proportion = 1. / 2.;}
          {proportion = 2. / 3.;}
          {proportion = 1. / 1.;}
        ];

        preset-window-heights = [
          {proportion = 1. / 3.;}
          {proportion = 1. / 2.;}
          {proportion = 2. / 3.;}
          {proportion = 1. / 1.;}
        ];

        always-center-single-column = true;
        center-focused-column = "never";

        default-column-width = {
          proportion = 1. / 2.;
        };

        default-column-display = "tabbed";

        tab-indicator = {
          enable = true;
          gap = 2;
          corner-radius = 4;
          hide-when-single-tab = true;
          place-within-column = true;
          width = 6;
          active.color = "#CD532C";
          inactive.color = "#6B5F5A";
          urgent.color = "#D4A017";
        };

        gaps = 6;

        struts = {
          bottom = 4;
          top = 4;
          left = 4;
          right = 4;
        };
      };

      gestures = {
        dnd-edge-view-scroll = {
          delay-ms = 400;
          trigger-width = 24;
        };

        dnd-edge-workspace-switch = {
          delay-ms = 400;
          trigger-height = 24;
        };

        hot-corners = {
          enable = true;
        };
      };
    };
  };
}
