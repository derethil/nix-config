{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
with internal; let
  cfg = config.apps.gdlauncher;

  pkg =
    if config.tools.nixgl.enable or false
    then config.lib.nixGL.wrap pkgs.gdlauncher-carbon
    else pkgs.gdlauncher-carbon;
in {
  options.apps.gdlauncher = {
    enable = mkBoolOpt false "Whether to enable GDLauncher-Carbon";
  };

  config.home.packages = with pkgs; [
    (mkIf cfg.enable pkg)
  ];
}
