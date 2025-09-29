{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.apps.bruno;
in {
  options.glace.apps.bruno = {
    enable = mkBoolOpt false "Whether to enable Bruno.";
  };

  config.home.packages = mkIf cfg.enable [
    pkgs.bruno
    pkgs.bruno-cli
  ];
}
