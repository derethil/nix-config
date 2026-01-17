{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.apps.spotify;
in {
  options.glace.apps.spotify = {
    enable = mkBoolOpt false "Whether to enable Spotify";
  };

  config = mkIf cfg.enable {
    home.packages = [
      pkgs.spotify
    ];
  };
}
