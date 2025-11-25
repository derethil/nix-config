{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.desktop.xdg;
in {
  options.glace.desktop.xdg = {
    enable = mkBoolOpt true "Whether to enable XDG base directory support";
  };

  config = mkIf cfg.enable {
    home = {
      sessionPath = ["~/.local/bin"];
      preferXdgDirectories = true;
      sessionVariables = {
        CUDA_CACHE_PATH = "${config.xdg.cacheHome}/nv";
      };
    };
    xdg = {
      enable = true;
      autostart.readOnly = true;
      cacheHome = "${config.home.homeDirectory}/.local/cache";
      userDirs = mkIf (pkgs.stdenv.hostPlatform.isLinux && config.glace.user.userdirs.enable) {
        enable = true;
        createDirectories = true;
        desktop = config.glace.user.userdirs.desktop;
        documents = config.glace.user.userdirs.documents;
        download = config.glace.user.userdirs.download;
        music = config.glace.user.userdirs.music;
        pictures = config.glace.user.userdirs.pictures;
        videos = config.glace.user.userdirs.videos;
        templates = config.glace.user.userdirs.templates;
        publicShare = config.glace.user.userdirs.publicShare;
        extraConfig = {
          XDG_SCREENSHOTS_DIR = "${config.glace.user.userdirs.pictures}/screenshots";
        };
      };
    };
  };
}
