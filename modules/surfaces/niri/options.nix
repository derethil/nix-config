{lib, ...}: let
  inherit (lib) mkOption types;
in {
  flake.modules.homeManager.niri-options = {
    key = "niri-options";
    options.surfaces.niri = {
      layout = {
        defaultColors = mkOption {
          type = types.bool;
          default = true;
          description = "Whether to apply niri's built-in color settings (disable when a panel like DMS owns them).";
        };
      };

      binds = {
        defaultAudioBinds = mkOption {
          type = types.bool;
          default = true;
          description = "Whether to bind the default audio control keys via wpctl.";
        };

        defaultBrightnessBinds = mkOption {
          type = types.bool;
          default = true;
          description = "Whether to bind the default brightness control keys via brightnessctl.";
        };
      };

      screenshots = {
        path = mkOption {
          type = types.str;
          default = "~/Pictures/screenshots";
          description = "Directory where screenshot files are written.";
        };
      };

      events = {
        defaultLidEvents = mkOption {
          type = types.bool;
          default = true;
          description = "Whether to bind default lid-close action (suspend).";
        };
      };
    };
  };
}
