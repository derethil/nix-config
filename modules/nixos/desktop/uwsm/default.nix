{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkMerge getExe getExe';
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.desktop.uwsm;
in {
  options.glace.desktop.uwsm = {
    enable = mkBoolOpt false "Whether to enable uwsm (Universal Wayland Session Manager).";
  };

  config = mkIf cfg.enable {
    programs.uwsm = {
      enable = true;
      waylandCompositors = mkMerge [
        (lib.mkIf config.glace.desktop.hyprland.enable {
          hyprland = {
            prettyName = "Hyprland";
            comment = "Hyprland managed by UWSM.";
            binPath = getExe pkgs.hyprland;
          };
        })

        (lib.mkIf config.glace.desktop.niri.enable {
          niri = {
            prettyName = "Niri";
            comment = "Niri managed by UWSM.";
            binPath = getExe' pkgs.niri-stable "niri-session";
          };
        })
      ];
    };
  };
}
