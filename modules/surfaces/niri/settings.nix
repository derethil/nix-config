{self, ...}: {
  flake.modules.homeManager.niri = {
    config,
    lib,
    ...
  }: let
    inherit (lib) mkIf mkMerge range;
    cfg = config.surfaces.niri;

    mkNumberedWorkspaces = count: (map (i: {_args = [(toString i)];}) (range 1 count));
  in {
    imports = [self.modules.homeManager.gtk];

    wayland.windowManager.niri.settings = {
      clipboard.disable-primary = [];

      cursor = {
        hide-when-typing = [];
        xcursor-size = config.home.pointerCursor.size;
        xcursor-theme = config.home.pointerCursor.name;
      };

      debug.honor-xdg-activation-with-invalid-serial = {};

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
          top-left = [];
          top-right = [];
        };
      };

      hotkey-overlay = {
        hide-not-bound = true;
        skip-at-startup = true;
      };

      input = {
        disable-power-key-handling = [];
        focus-follows-mouse = [];

        mouse = {
          accel-profile = "flat";
          accel-speed = 0.3;
        };

        touchpad = {
          accel-profile = "adaptive";
          click-method = "clickfinger";
          disabled-on-external-mouse = [];
          drag = true;
          dwt = [];
          middle-emulation = [];
          natural-scroll = [];
          tap = [];
          tap-button-map = "left-right-middle";
        };

        warp-mouse-to-focus._props.mode = "center-xy";
        workspace-auto-back-and-forth = [];
      };

      layout = {
        always-center-single-column = [];
        background-color = "transparent";

        border = mkMerge [
          (mkIf cfg.layout.defaultColors {
            active-color = "#BEC8CD";
            inactive-color = "#131314";
            urgent-color = "#92B2D3";
          })
          {width = 2;}
        ];

        center-focused-column = "never";
        default-column-display = "normal";
        default-column-width.proportion = 1.0 / 2.0;
        focus-ring.off = [];
        gaps = 6;

        insert-hint = mkIf cfg.layout.defaultColors {
          color = "#A79087";
        };

        preset-column-widths._children = [
          {proportion = 1.0 / 1.0;}
          {proportion = 1.0 / 2.0;}
          {proportion = 1.0 / 3.0;}
          {proportion = 2.0 / 3.0;}
        ];

        preset-window-heights._children = [
          {proportion = 1.0 / 1.0;}
          {proportion = 1.0 / 2.0;}
          {proportion = 1.0 / 3.0;}
          {proportion = 2.0 / 3.0;}
        ];

        struts = {
          bottom = 4;
          left = 4;
          right = 4;
          top = 4;
        };

        tab-indicator = mkMerge [
          (mkIf cfg.layout.defaultColors {
            active-color = "#CD532C";
            inactive-color = "#6B5F5A";
            urgent-color = "#D4A017";
          })
          {
            corner-radius = 4;
            gap = 2;
            gaps-between-tabs = 0;
            hide-when-single-tab = [];
            length._props.total-proportion = 0.5;
            place-within-column = [];
            position = "left";
            width = 6;
          }
        ];
      };

      prefer-no-csd = true;

      recent-windows = mkMerge [
        (mkIf cfg.layout.defaultColors {
          highlight = {
            active = "#BEC8CD";
            urgent = "#92B2D3";
          };
        })
        {
          debounce-ms = 750;

          highlight = {
            corner-radius = 4;
            padding = 18;
          };

          open-delay-ms = 150;

          previews = {
            max-height = 840;
            max-scale = 0.65;
          };
        }
      ];

      screenshot-path = "${cfg.screenshots.path}/%Y-%m-%d_%H-%M-%S.png";

      switch-events = mkIf cfg.events.defaultLidEvents {
        lid-close.spawn = ["suspend" "systemctl"];
      };

      workspace = mkNumberedWorkspaces 5;
    };
  };
}
