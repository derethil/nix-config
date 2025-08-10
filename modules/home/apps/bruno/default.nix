{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
with internal; let
  cfg = config.apps.bruno;
in {
  options.apps.bruno = {
    enable = mkBoolOpt false "Whether to enable Bruno.";
  };

  config.home.packages = mkIf cfg.enable [
    pkgs.bruno
    pkgs.bruno-cli
  ];
}
