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
    wayland.windowManager.niri.settings.xwayland-satellite = {
      path = getExe pkgs.unstable.xwayland-satellite;
    };
  };
}
