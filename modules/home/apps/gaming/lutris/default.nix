{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.apps.gaming.lutris;
in {
  options.glace.apps.gaming.lutris = {
    enable = mkBoolOpt false "Whether to enable Lutris gaming platform";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      lutris
    ];
  };
}