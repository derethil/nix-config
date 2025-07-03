{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
with internal; let
  cfg = config.apps.obs;
in {
  options.apps.obs = {
    enable = mkBoolOpt false "Whether to enable OBS Studio";
  };

  config.home.packages = with pkgs; [
    (mkIf cfg.enable obs-studio)
  ];
}
