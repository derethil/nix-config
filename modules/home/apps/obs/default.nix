{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.apps.obs;
in {
  options.glace.apps.obs = {
    enable = mkBoolOpt false "Whether to enable OBS Studio";
  };

  config = mkIf cfg.enable {
    home.packages = [pkgs.obs-studio];
  };
}
