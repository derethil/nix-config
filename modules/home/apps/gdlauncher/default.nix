{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
with glace; let
  cfg = config.glace.apps.gdlauncher;

  pkg =
    if config.glace.tools.nixgl.enable or false
    then config.lib.nixGL.wrap pkgs.gdlauncher-carbon
    else pkgs.gdlauncher-carbon;
in {
  options.glace.apps.gdlauncher = {
    enable = mkBoolOpt false "Whether to enable GDLauncher-Carbon";
  };

  config.home.packages = with pkgs; [
    (mkIf cfg.enable pkg)
  ];
}
