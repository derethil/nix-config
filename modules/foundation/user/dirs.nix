{
  flake.modules.homeManager.user-dirs = {
    config,
    lib,
    pkgs,
    ...
  }: {
    home = {
      preferXdgDirectories = true;
      sessionPath = ["${config.home.homeDirectory}/.local/bin"];
      sessionVariables = {
        CUDA_CACHE_PATH = "${config.xdg.cacheHome}/nv";
        # Use system portals instead of home-manager's default
        # See: https://github.com/nix-community/home-manager/issues/7124
        NIX_XDG_DESKTOP_PORTAL_DIR = lib.mkForce "/run/current-system/sw/share/xdg-desktop-portal/portals";
        # Fix for Qt apps crashing due to missing GSettings schemas
        # https://github.com/NixOS/nixpkgs/issues/149812
        XDG_DATA_DIRS = "$XDG_DATA_DIRS:${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}";
      };
    };

    xdg = {
      enable = true;
      autostart.readOnly = true;
      cacheHome = "${config.home.homeDirectory}/.local/cache";
      userDirs = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
        enable = true;
        createDirectories = true;
        setSessionVariables = true;
        desktop = "${config.home.homeDirectory}/Desktop";
        documents = "${config.home.homeDirectory}/Documents";
        download = "${config.home.homeDirectory}/Downloads";
        music = "${config.home.homeDirectory}/Music";
        pictures = "${config.home.homeDirectory}/Pictures";
        videos = "${config.home.homeDirectory}/Videos";
        templates = "${config.home.homeDirectory}/Templates";
        publicShare = "${config.home.homeDirectory}/Public";
        extraConfig.SCREENSHOTS = "${config.home.homeDirectory}/Pictures/screenshots";
      };
    };
  };
}
