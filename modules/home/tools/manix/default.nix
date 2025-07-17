{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
with internal; let
  cfg = config.tools.manix;
in {
  options.tools.manix = {
    enable = mkBoolOpt false "Whether to enable Manix.";
  };

  config = mkIf cfg.enable {
    home.packages = [pkgs.manix];
  };
}
