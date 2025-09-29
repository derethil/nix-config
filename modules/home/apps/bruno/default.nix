{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
with glace; let
  cfg = config.glace.apps.bruno;
in {
  options.glace.apps.bruno = {
    enable = mkBoolOpt false "Whether to enable Bruno.";
  };

  config.home.packages = mkIf cfg.enable [
    pkgs.bruno
    pkgs.bruno-cli
  ];
}
