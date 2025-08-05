{
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.desktop.aerospace;
in {
  config = mkIf cfg.enable {
    programs.aerospace.userSettings = {
      after-startup-command = [];
      default-root-container-layout = "tiles";
      default-root-container-orientation = "auto";
      on-focused-monitor-changed = ["move-mouse monitor-lazy-center"];
      on-focus-changed = ["move-mouse window-lazy-center"];
      accordion-padding = 30;
      enable-normalization-flatten-containers = true;
      automatically-unhide-macos-hidden-apps = true; # effectively turn off cmd+h

      workspace-to-monitor-force-assignment = {
        "1" = "main";
        "2" = "main";
        "3" = "main";
        "4" = "main";
        "5" = "main";
      };

      gaps = {
        inner.horizontal = 4;
        inner.vertical = 4;
        outer.left = 8;
        outer.bottom = 8;
        outer.top = 8;
        outer.right = 8;
      };

      key-mapping = {
        preset = "qwerty";
      };
    };
  };
}
