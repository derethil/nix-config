{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib.internal) mkOpt mkBoolOpt;
  inherit (lib.types) str nullOr;
  inherit (pkgs.stdenv.hostPlatform) isDarwin;

  defaultPaths = {
    desktop = "${config.home.homeDirectory}/Desktop";
    documents = "${config.home.homeDirectory}/Documents";
    download = "${config.home.homeDirectory}/Downloads";
    music = "${config.home.homeDirectory}/Music";
    pictures = "${config.home.homeDirectory}/Pictures";
    videos = "${config.home.homeDirectory}/Videos";
    templates = "${config.home.homeDirectory}/Templates";
    publicShare = "${config.home.homeDirectory}/Public";
  };

  darwinDefaultPaths =
    defaultPaths
    // {
      videos = "Users/${config.user.name}/Movies";
    };

  paths =
    if isDarwin
    then darwinDefaultPaths
    else defaultPaths;
in {
  options.user.userdirs = {
    enable = mkBoolOpt false "user directories configuration";

    desktop = mkOpt (nullOr str) paths.desktop "Desktop directory path";
    documents = mkOpt (nullOr str) paths.documents "Documents directory path";
    download = mkOpt (nullOr str) paths.download "Downloads directory path";
    music = mkOpt (nullOr str) paths.music "Music directory path";
    pictures = mkOpt (nullOr str) paths.pictures "Pictures directory path";
    videos = mkOpt (nullOr str) paths.videos "Videos directory path";
    templates = mkOpt (nullOr str) paths.templates "Templates directory path";
    publicShare = mkOpt (nullOr str) paths.publicShare "Public share directory path";
  };
}
