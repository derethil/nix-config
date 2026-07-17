{
  self,
  lib,
  ...
}: let
  inherit (lib) mkOption types;

  positionType = types.submodule {
    options = {
      x = mkOption {
        type = types.int;
        default = 0;
      };
      y = mkOption {
        type = types.int;
        default = 0;
      };
    };
  };

  resolutionType = types.submodule {
    options = {
      width = mkOption {type = types.int;};
      height = mkOption {type = types.int;};
    };
  };

  displayType = types.submodule {
    options = {
      name = mkOption {
        type = types.str;
        description = "Human-readable name for the monitor.";
      };
      port = mkOption {
        type = types.str;
        description = "Monitor port/connector name (e.g. DP-1).";
      };
      resolution = mkOption {
        type = resolutionType;
        description = "Monitor resolution.";
      };
      framerate = mkOption {
        type = types.int;
        description = "Monitor refresh rate in Hz.";
      };
      position = mkOption {
        type = positionType;
        default = {};
        description = "Monitor position coordinates.";
      };
      scale = mkOption {
        type = types.float;
        default = 1.0;
        description = "Scaling factor for the monitor.";
      };
      enabled = mkOption {
        type = types.bool;
        default = true;
        description = "Whether the monitor is enabled.";
      };
      rotation = mkOption {
        type = types.enum [0 90 180 270];
        default = 0;
        description = "Monitor rotation in degrees.";
      };
      flipped = mkOption {
        type = types.bool;
        default = false;
        description = "Whether the monitor is flipped vertically.";
      };
      primary = mkOption {
        type = types.bool;
        default = false;
        description = "Whether this is the primary monitor.";
      };
      vrr = mkOption {
        type = types.either types.bool (types.enum ["on-demand"]);
        default = false;
        description = ''
          Variable refresh rate setting: `false` (off), `"on-demand"`, or `true` (always on).
        '';
      };
      wallpaper = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Path to the wallpaper for this monitor.";
      };
    };
  };
in {
  flake.modules = {
    generic.displays-options = {config, ...}: {
      key = "displays-options";

      options.internal.displays = mkOption {
        type = types.listOf displayType;
        default = [];
        description = ''
          Monitors physically attached to this host. Set on the system module;
          propagated to every home-manager user on the host via
          home-manager.sharedModules so user-level consumers see the same list.
        '';
      };

      options.internal.primaryDisplay = mkOption {
        type = displayType;
        readOnly = true;
        description = ''
          The display marked `primary = true`. Throws at access time if no
          display is marked primary, so consumers don't have to handle the
          "no primary" case themselves.
        '';
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

    homeManager.displays = {
      imports = [self.modules.generic.displays-options];
    };
  };
}
