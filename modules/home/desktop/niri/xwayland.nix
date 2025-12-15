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
      # NOTE: need 0.8 to fix steam crash, once 0.8 has been backported to nixpkgs stable revert this
      path = getExe pkgs.unstable.xwayland-satellite;
    };
  };
}
