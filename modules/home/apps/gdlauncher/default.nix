{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
with internal; let
  cfg = config.apps.gdlauncher;
in {
  options.apps.gdlauncher = {
    enable = mkBoolOpt false "Whether to enable GDLauncher-Carbon";
  };

  config.home.packages = with pkgs; [
    (mkIf cfg.enable gdlauncher-carbon)
  ];
}
