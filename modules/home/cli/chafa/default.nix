{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with internal; let
  cfg = config.cli.chafa;
in {
  options.cli.chafa = {
    enable = mkBoolOpt false "Whether to enable Chafa terminal image viewer.";
  };

  config = mkIf cfg.enable {
    home.packages = [pkgs.chafa];
  };
}