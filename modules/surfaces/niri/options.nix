{lib, ...}: let
  inherit (lib) mkOption types;
in {
  flake.modules.homeManager.niri-options = {
    key = "niri-options";

    options.surfaces.niri = {
      binds = {
        defaultAudioBinds = mkOption {
          default = true;
          description = "Whether to bind the default audio control keys via wpctl.";
          type = types.bool;
        };

        defaultBrightnessBinds = mkOption {
          default = true;
          description = "Whether to bind the default brightness control keys via brightnessctl.";
          type = types.bool;
        };
      };

      events.defaultLidEvents = mkOption {
        default = true;
        description = "Whether to bind default lid-close action (suspend).";
        type = types.bool;
      };

      layout.defaultColors = mkOption {
        default = true;
        description = "Whether to apply niri's built-in color settings (disable when a panel like DMS owns them).";
        type = types.bool;
      };

      screenshots.path = mkOption {
        default = "~/Pictures/screenshots";
        description = "Directory where screenshot files are written.";
        type = types.str;
      };
    };
  };
}
