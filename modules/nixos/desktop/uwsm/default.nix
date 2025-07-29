{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
with internal; let
  cfg = config.desktop.uwsm;
  nixgl = config.tools.nixgl;
in {
  options.desktop.uwsm = with types; {
    enable = mkBoolOpt false "Whether to enable uwsm (universal wayland session manager).";
  };

  config = mkIf cfg.enable {
    programs.uwsm = {
      enable = true;
      waylandCompositors = {
        hyprland = mkIf config.desktop.hyprland.enable {
          prettyName = "Hyprland";
          comment = "Hyprland compositor";
          binPath = mkMerge [
            (mkIf (!nixgl.enabled) (getExe pkgs.hyprland))
            (mkIf (nixgl.enabled) (getExe (config.lib.nixGL.wrap pkgs.hyprland)))
          ];
          desktopNames = ["Hyprland"];
        };
      };
    };
  };
}
