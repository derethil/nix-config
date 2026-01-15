{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.apps.gaming.melonloader;
in {
  options.glace.apps.gaming.melonloader = {
    enable = mkBoolOpt false "Whether to enable Melon Loader";
  };

  config = mkIf cfg.enable {
    home.packages = [
      pkgs.glace.melonloader
    ];
  };
}
