{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf getExe';
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.desktop.niri;
in {
  imports = [
    ./nvidia.nix
  ];

  options.glace.desktop.niri = {
    enable = mkBoolOpt false "Whether to enable niri desktop environment.";
  };

  config = mkIf cfg.enable {
    glace.services.portals = {
      enable = true;
      portals = [pkgs.xdg-desktop-portal-gtk pkgs.xdg-desktop-portal-gnome];
      config.niri.default = ["gtk" "gnome"];
    };

    glace.desktop.displayManagers.sessions = {
      enable = true;
      sessionPackages = {
        niri-session = {
          desktopName = "Niri";
          comment = "Niri Desktop Environment";
          exec = getExe' pkgs.niri-stable "niri-session";
        };
      };
    };
  };
}
