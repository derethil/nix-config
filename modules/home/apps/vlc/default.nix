{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.apps.vlc;
in {
  options.glace.apps.vlc = {
    enable = mkBoolOpt false "Whether to enable VLC";
  };

  config = mkIf cfg.enable {
    home.packages = [pkgs.vlc];
  };
}
