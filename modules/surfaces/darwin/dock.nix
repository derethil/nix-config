{lib, ...}: {
  flake.modules.darwin.dock = {config, ...}: let
    inherit (lib) mkOption types;
  in {
    options.internal.dock.apps = mkOption {
      type = types.listOf types.attrs;
      default = [];
      description = "Persistent app entries shown on the Dock.";
    };

    config.system.defaults.dock = {
      appswitcher-all-displays = true;
      show-recents = false;
      static-only = false;
      show-process-indicators = true;
      launchanim = true;
      scroll-to-open = true;

      mineffect = "scale";
      minimize-to-application = true;

      autohide = true;
      autohide-delay = 0.24;
      autohide-time-modifier = 1.0;

      enable-spring-load-actions-on-all-items = true;
      expose-animation-duration = 0.8;

      expose-group-apps = true;
      mru-spaces = false;

      persistent-others = [];
      persistent-apps = config.internal.dock.apps;
    };
  };
}
