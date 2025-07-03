{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
with internal; let
  cfg = config.apps.r2modman;
in {
  options.apps.r2modman = {
    enable = mkBoolOpt false "Whether to enable r2modman";
  };

  config.home.packages = with pkgs; [
    (mkIf cfg.enable r2modman)
  ];
}
