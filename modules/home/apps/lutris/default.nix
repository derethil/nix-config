{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.apps.lutris;
in {
  options.glace.apps.lutris = {
    enable = mkBoolOpt false "Whether to enable Lutris gaming platform";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      lutris
    ];
  };
}