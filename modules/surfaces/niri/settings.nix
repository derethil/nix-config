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
      workspace = mkNumberedWorkspaces 5;

      switch-events = mkIf cfg.events.defaultLidEvents {
        lid-close.spawn = ["systemctl" "suspend"];
      };

      screenshot-path = "${cfg.screenshots.path}/%Y-%m-%d_%H-%M-%S.png";

      hotkey-overlay = {
        hide-not-bound = true;
        skip-at-startup = true;
      };

      prefer-no-csd = true;

      input = {
        focus-follows-mouse = [];

        mouse = {
          accel-speed = 0.3;
          accel-profile = "flat";
        };

        touchpad = {
          middle-emulation = [];
          click-method = "clickfinger";
          tap = [];
          tap-button-map = "left-right-middle";
          accel-profile = "adaptive";
          disabled-on-external-mouse = [];
          drag = true;
          dwt = [];
          natural-scroll = [];
        };

        disable-power-key-handling = [];

        warp-mouse-to-focus._props.mode = "center-xy";

        workspace-auto-back-and-forth = [];
      };

      clipboard.disable-primary = [];

      cursor = {
        hide-when-typing = [];
        xcursor-theme = config.home.pointerCursor.name;
        xcursor-size = config.home.pointerCursor.size;
      };

      layout = {
        gaps = 6;

        border = mkMerge [
          {width = 2;}
          (mkIf cfg.layout.defaultColors {
            active-color = "#BEC8CD";
            inactive-color = "#131314";
            urgent-color = "#92B2D3";
          })
        ];

        background-color = "transparent";

        struts = {
          left = 4;
          right = 4;
          top = 4;
          bottom = 4;
        };

        focus-ring.off = [];

        insert-hint = mkIf cfg.layout.defaultColors {
          color = "#A79087";
        };

        preset-column-widths._children = [
          {proportion = 1.0 / 3.0;}
          {proportion = 1.0 / 2.0;}
          {proportion = 2.0 / 3.0;}
          {proportion = 1.0 / 1.0;}
        ];

        preset-window-heights._children = [
          {proportion = 1.0 / 3.0;}
          {proportion = 1.0 / 2.0;}
          {proportion = 2.0 / 3.0;}
          {proportion = 1.0 / 1.0;}
        ];

        always-center-single-column = [];
        center-focused-column = "never";

        default-column-display = "normal";
        default-column-width.proportion = 1.0 / 2.0;

        tab-indicator = mkMerge [
          {
            gap = 2;
            width = 6;
            corner-radius = 4;
            position = "left";
            length._props.total-proportion = 0.5;
            gaps-between-tabs = 0;
            hide-when-single-tab = [];
            place-within-column = [];
          }
          (mkIf cfg.layout.defaultColors {
            active-color = "#CD532C";
            inactive-color = "#6B5F5A";
            urgent-color = "#D4A017";
          })
        ];
      };

      recent-windows = mkMerge [
        {
          debounce-ms = 750;
          open-delay-ms = 150;
          highlight = {
            padding = 18;
            corner-radius = 4;
          };
          previews = {
            max-scale = 0.65;
            max-height = 840;
          };
        }
        (mkIf cfg.layout.defaultColors {
          highlight = {
            active = "#BEC8CD";
            urgent = "#92B2D3";
          };
        })
      ];

      gestures = {
        hot-corners = {
          top-right = [];
          top-left = [];
        };
        dnd-edge-view-scroll = {
          delay-ms = 400;
          trigger-width = 24;
        };
        dnd-edge-workspace-switch = {
          delay-ms = 400;
          trigger-height = 24;
        };
      };

      debug = {
        honor-xdg-activation-with-invalid-serial = {};
      };
    };
  };
}
