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
    targetDir = mkOpt path "${config.xdg.userDirs.pictures}/wallpapers" "Directory where wallpapers will be stored.";
    sourceDir = mkOpt path ./wallpapers "Source directory for wallpapers.";
  };

  config = mkIf cfg.enable {
    home.file.${cfg.targetDir}.source = cfg.sourceDir;
  };
}
