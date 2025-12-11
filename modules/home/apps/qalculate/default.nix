{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.apps.qalculate;
in {
  options.glace.apps.qalculate = {
    enable = mkBoolOpt false "Whether to enable Qalculate";
  };

  config = mkIf cfg.enable {
    home.packages = [
      pkgs.qalculate-gtk # App
      pkgs.libqalculate # CLI / Core library
    ];
  };
}
