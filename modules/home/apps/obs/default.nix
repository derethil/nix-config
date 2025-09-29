{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
with glace; let
  cfg = config.glace.apps.obs;
in {
  options.glace.apps.obs = {
    enable = mkBoolOpt false "Whether to enable OBS Studio";
  };

  config.home.packages = with pkgs; [
    (mkIf cfg.enable obs-studio)
  ];
}
