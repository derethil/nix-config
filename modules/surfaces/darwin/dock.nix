{lib, ...}: {
  flake.modules.darwin.dock = {config, ...}: let
    inherit (lib) mkOption types;
  in {
    options.internal.dock.apps = mkOption {
      default = [];
      description = "Persistent app entries shown on the Dock.";
      type = types.listOf types.attrs;
    };

    config.system.defaults.dock = {
      appswitcher-all-displays = true;
      autohide = true;
      autohide-delay = 0.24;
      autohide-time-modifier = 1.0;
      enable-spring-load-actions-on-all-items = true;
      expose-animation-duration = 0.8;
      expose-group-apps = true;
      launchanim = true;
      mineffect = "scale";
      minimize-to-application = true;
      mru-spaces = false;
      persistent-apps = config.internal.dock.apps;
      persistent-others = [];
      scroll-to-open = true;
      show-process-indicators = true;
      show-recents = false;
      static-only = false;
    };
  };
}
