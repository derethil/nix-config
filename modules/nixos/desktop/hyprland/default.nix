{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.desktop.hyprland;
in {
  options.glace.desktop.hyprland = {
    enable = mkBoolOpt false "Whether to enable Hyprland desktop environment.";
  };

  config = mkIf cfg.enable {
    glace.services.portals = {
      enable = true;
      portals = [pkgs.xdg-desktop-portal-hyprland pkgs.xdg-desktop-portal-gtk];
      config.hyprland.default = ["hyprland" "gtk"];
    };
  };
}
