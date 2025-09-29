{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.apps.heroic;
in {
  options.glace.apps.heroic = {
    enable = mkBoolOpt false "Whether to enable Heroic Games Launcher";
  };

  config.home.packages = with pkgs; [
    (mkIf cfg.enable heroic)
  ];
}
