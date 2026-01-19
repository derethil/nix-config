{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.apps.pinta;
in {
  options.glace.apps.pinta = {
    enable = mkBoolOpt false "Whether to enable pinta";
  };

  config = mkIf cfg.enable {
    home.packages = [
      pkgs.pinta
    ];
  };
}
