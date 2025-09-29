{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.apps.obsidian;
in {
  options.glace.apps.obsidian = {
    enable = mkBoolOpt false "Whether to enable Obsidian";
  };

  config = mkIf cfg.enable {
    home.packages = [pkgs.obsidian];
  };
}
