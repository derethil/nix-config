{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
with internal; let
  cfg = config.apps.obsidian;
in {
  options.apps.obsidian = {
    enable = mkBoolOpt false "Whether to enable Obsidian";
  };

  config.home.packages = with pkgs; [
    (mkIf cfg.enable obsidian)
  ];
}
