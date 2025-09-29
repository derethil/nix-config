{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.apps.gdlauncher;
in {
  options.glace.apps.gdlauncher = {
    enable = mkBoolOpt false "Whether to enable GDLauncher-Carbon";
  };

  config = mkIf cfg.enable {
    home.packages =
      if config.glace.tools.nixgl.enable or false
      then [config.lib.nixGL.wrap pkgs.gdlauncher-carbon]
      else [pkgs.gdlauncher-carbon];
  };
}
