{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
with internal; let
  cfg = config.apps.spotify;
in {
  options.apps.spotify = {
    enable = mkBoolOpt false "Whether to enable Spotify";
  };

  config.home.packages = with pkgs; [
    (mkIf cfg.enable spotify)
  ];
}
