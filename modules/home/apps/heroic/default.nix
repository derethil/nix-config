{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
with internal; let
  cfg = config.apps.heroic;
in {
  options.apps.heroic = {
    enable = mkBoolOpt false "Whether to enable Heroic Games Launcher";
  };

  config.home.packages = with pkgs; [
    (mkIf cfg.enable heroic)
  ];
}
