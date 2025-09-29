{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
with glace; let
  cfg = config.glace.apps.obsidian;
in {
  options.glace.apps.obsidian = {
    enable = mkBoolOpt false "Whether to enable Obsidian";
  };

  config.home.packages = with pkgs; [
    (mkIf cfg.enable obsidian)
  ];
}
