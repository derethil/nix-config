{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
with glace; let
  cfg = config.glace.tools.manix;
in {
  options.glace.tools.manix = {
    enable = mkBoolOpt false "Whether to enable Manix.";
  };

  config = mkIf cfg.enable {
    home.packages = [pkgs.manix];
  };
}
