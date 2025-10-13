{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
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
      portals = [pkgs.xdg-desktop-portal-gnome];
      config.niri.default = ["gnome" "gtk"];
    };
  };
}

