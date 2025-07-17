{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
with internal; let
  cfg = config.desktop.uwsm;
in {
  options.desktop.uwsm = with types; {
    enable = mkBoolOpt false "Whether to enable uwsm (universal wayland session manager).";
  };

  config = mkIf cfg.enable {
    programs.uwsm = {
      enable = true;
      waylandCompositors = {
        hyprland = {
          prettyName = "Hyprland";
          comment = "Hyprland compositor";
          binPath = "${pkgs.hyprland}/bin/Hyprland";
          desktopNames = ["Hyprland"];
        };
      };
    };
  };
}