{
  lib,
  config,
  ...
}:
with lib;
with internal; let
  cfg = config.desktop.addons.wallpapers;
in {
  options.desktop.addons.wallpapers = with types; {
    enable = mkBoolOpt false "Enable wallpapers synchronization.";
    targetDir = mkOpt path "${config.home.homeDirectory}/Pictures/wallpapers" "Directory where wallpapers will be stored.";
  };

  config = mkIf cfg.enable {
    home.file.${cfg.targetDir}.source = ./wallpapers;
  };
}
