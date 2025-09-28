{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkMerge getExe;
  inherit (lib.internal) mkBoolOpt;
  cfg = config.desktop.uwsm;
in {
  options.desktop.uwsm = {
    enable = mkBoolOpt false "Whether to enable uwsm (Universal Wayland Session Manager).";
  };

  config = mkIf cfg.enable {
    programs.uwsm = {
      enable = true;
      waylandCompositors = mkMerge [
        (lib.mkIf config.desktop.hyprland.enable {
          hyprland = {
            prettyName = "Hyprland";
            comment = "Hyprland managed by UWSM.";
            binPath = getExe pkgs.hyprland;
          };
        })
      ];
    };
  };
}
