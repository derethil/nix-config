{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf recursiveUpdate;
  cfg = config.glace.desktop.niri;

  materialDesignDecelerate = {
    easing = {
      curve = "cubic-bezier";
      curve-args = [0.05 0.7 0.1 1.0];
      duration-ms = 200;
    };
  };

  materialDesignAccelerate = {
    easing = {
      curve = "cubic-bezier";
      curve-args = [0.3 0.0 0.8 0.15];
      duration-ms = 150;
    };
  };

  menuDecelerate = {
    easing = {
      curve = "cubic-bezier";
      curve-args = [0.1 1.0 0.0 1.0];
      duration-ms = 200;
    };
  };

  menuAccelerate = {
    easing = {
      curve = "cubic-bezier";
      curve-args = [0.38 0.04 1.0 0.07];
      duration-ms = 100;
    };
  };
in {
  config = mkIf cfg.enable {
    programs.niri.settings = {
      animations = {
        enable = true;

        # UI

        exit-confirmation-open-close = {
          enable = true;
          kind = menuDecelerate;
        };

        screenshot-ui-open = {
          enable = true;
          kind = menuDecelerate;
        };

        # Camera

        horizontal-view-movement = {
          enable = true;
          kind = materialDesignDecelerate;
        };

        overview-open-close = {
          enable = true;
          kind = menuDecelerate;
        };

        # Windows

        window-open = {
          enable = true;
          kind = materialDesignDecelerate;
        };

        window-close = {
          enable = true;
          kind = materialDesignAccelerate;
        };

        window-movement = {
          enable = true;
          kind = materialDesignDecelerate;
        };

        window-resize = {
          enable = true;
          kind = materialDesignDecelerate;
        };

        workspace-switch = {
          enable = true;
          kind = recursiveUpdate menuDecelerate {
            easing.duration-ms = 600;
          };
        };
      };
    };
  };
}
