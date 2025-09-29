{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.tools.manix;
in {
  options.glace.tools.manix = {
    enable = mkBoolOpt false "Whether to enable Manix.";
  };

  config = mkIf cfg.enable {
    home.packages = [pkgs.manix];
  };
}
