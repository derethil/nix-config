{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with glace; let
  cfg = config.glace.cli.chafa;
in {
  options.glace.cli.chafa = {
    enable = mkBoolOpt false "Whether to enable Chafa terminal image viewer.";
  };

  config = mkIf cfg.enable {
    home.packages = [pkgs.chafa];
  };
}