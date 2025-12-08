{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkForce;
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
        # Override home-manager's default to use system portals, dunno why it's being set but it is
        # See: https://github.com/nix-community/home-manager/issues/7124
        NIX_XDG_DESKTOP_PORTAL_DIR = mkForce "/run/current-system/sw/share/xdg-desktop-portal/portals";
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
