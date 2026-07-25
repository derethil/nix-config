{
  self,
  lib,
  ...
}: let
  inherit (lib) mkOption types;

  positionType = types.submodule {
    options = {
      x = mkOption {
        default = 0;
        type = types.int;
      };

      y = mkOption {
        default = 0;
        type = types.int;
      };
    };
  };

  resolutionType = types.submodule {
    options = {
      height = mkOption {type = types.int;};
      width = mkOption {type = types.int;};
    };
  };

  displayType = types.submodule {
    options = {
      enabled = mkOption {
        default = true;
        description = "Whether the monitor is enabled.";
        type = types.bool;
      };

      flipped = mkOption {
        default = false;
        description = "Whether the monitor is flipped vertically.";
        type = types.bool;
      };

      framerate = mkOption {
        description = "Monitor refresh rate in Hz.";
        type = types.int;
      };

      name = mkOption {
        description = "Human-readable name for the monitor.";
        type = types.str;
      };

      port = mkOption {
        description = "Monitor port/connector name (e.g. DP-1).";
        type = types.str;
      };

      position = mkOption {
        default = {};
        description = "Monitor position coordinates.";
        type = positionType;
      };

      primary = mkOption {
        default = false;
        description = "Whether this is the primary monitor.";
        type = types.bool;
      };

      resolution = mkOption {
        description = "Monitor resolution.";
        type = resolutionType;
      };

      rotation = mkOption {
        default = 0;
        description = "Monitor rotation in degrees.";
        type = types.enum [0 180 270 90];
      };

      scale = mkOption {
        default = 1.0;
        description = "Scaling factor for the monitor.";
        type = types.float;
      };

      vrr = mkOption {
        default = false;

        description = ''
          Variable refresh rate setting: `false` (off), `"on-demand"`, or `true` (always on).
        '';

        type = types.either types.bool (types.enum ["on-demand"]);
      };

      wallpaper = mkOption {
        default = null;
        description = "Path to the wallpaper for this monitor.";
        type = types.nullOr types.str;
      };
    };
  };
in {
  flake.modules = {
    generic.displays-options = {config, ...}: {
      key = "displays-options";

      options.internal = {
        displays = mkOption {
          default = [];

          description = ''
            Monitors physically attached to this host. Set on the system module;
            propagated to every home-manager user on the host via
            home-manager.sharedModules so user-level consumers see the same list.
          '';

          type = types.listOf displayType;
        };

        primaryDisplay = mkOption {
          description = ''
            The display marked `primary = true`. Throws at access time if no
            display is marked primary, so consumers don't have to handle the
            "no primary" case themselves.
          '';

          readOnly = true;
          type = displayType;
        };
      };

      config.internal.primaryDisplay = let
        found = lib.findFirst (d: d.primary) null config.internal.displays;
      in
        if found == null
        then throw "displays: no display has `primary = true`"
        else found;
    };

    nixos.displays = {config, ...}: {
      imports = [self.modules.generic.displays-options];

      config.home-manager.sharedModules = [
        self.modules.homeManager.displays
        {internal.displays = lib.mkDefault config.internal.displays;}
      ];
    };

    darwin.displays = {config, ...}: {
      imports = [self.modules.generic.displays-options];

      config.home-manager.sharedModules = [
        self.modules.homeManager.displays
        {internal.displays = lib.mkDefault config.internal.displays;}
      ];
    };

    homeManager.displays.imports = [self.modules.generic.displays-options];
  };
}
