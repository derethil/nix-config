{
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf types;
  inherit (lib.glace) mkBoolOpt mkOpt;
  cfg = config.glace.desktop.addons.wallpapers;
in {
  options.glace.desktop.addons.wallpapers = with types; {
    enable = mkBoolOpt false "Enable wallpapers synchronization.";
    targetDir = mkOpt path "${config.glace.user.userdirs.pictures}/wallpapers" "Directory where wallpapers will be stored.";
    sourceDir = mkOpt path ./wallpapers "Source directory for wallpapers.";
  };

  config = mkIf cfg.enable {
    home.file.${cfg.targetDir}.source = cfg.sourceDir;
  };
}
