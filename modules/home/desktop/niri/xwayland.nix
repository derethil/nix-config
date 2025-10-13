{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf getExe;
  cfg = config.glace.desktop.niri;
in {
  config = mkIf cfg.enable {
    programs.niri.settings.xwayland-satellite = {
      enable = true;
      path = getExe pkgs.xwayland-satellite-unstable;
    };
  };
}