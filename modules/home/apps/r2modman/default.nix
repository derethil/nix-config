{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.apps.r2modman;
in {
  options.glace.apps.r2modman = {
    enable = mkBoolOpt false "Whether to enable r2modman";
  };

  config.home.packages = with pkgs; [
    (mkIf cfg.enable r2modman)
  ];
}
