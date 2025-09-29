{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
with glace; let
  cfg = config.glace.apps.spotify;
in {
  options.glace.apps.spotify = {
    enable = mkBoolOpt false "Whether to enable Spotify";
  };

  config.home.packages = with pkgs; [
    (mkIf cfg.enable spotify)
  ];
}
