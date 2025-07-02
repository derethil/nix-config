{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with internal; let
  cfg = config.cli.trashy;
in {
  options.cli.trashy = {
    enable = mkBoolOpt false "Whether to enable Trashy.";
  };

  config = mkIf cfg.enable {
    home.packages = [pkgs.inputs.trashy];
  };
}
