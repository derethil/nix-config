{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
with internal; let
  cfg = config.desktop.xdg;

  cacheHome = config.xdg.cacheHome;
  configHome = config.xdg.configHome;
  dataHome = config.xdg.dataHome;

  # TODO: This will likely be obsolute once all of these things are configured by Nix.
  # I'd rather place each variable in the configuration of its associated tool.
  sessionVariables = {
    # ASDF
    ASDF_CONFIG_FILE = "${configHome}/asdf/asdfrc";
    ASDF_DATA_DIR = "${dataHome}/asdf";

    # Bun
    BUN_INSTALL = "${dataHome}/bun";

    # Ruby Bundle
    BUNDLE_USER_CACHE = "${cacheHome}/bundle";
    BUNDLE_USER_CONFIG = "${configHome}/bundle/config";
    BUNDLE_USER_PLUGIN = "${dataHome}/bundle";

    # Cargo / Rust
    CARGO_HOME = "${dataHome}/cargo";
    RUSTUP_HOME = "${dataHome}/rustup";

    # Docker
    DOCKER_CONFIG = "${configHome}/docker";

    # Histfile
    HISTFILE = "${dataHome}/bash/history";

    # IRB
    IRBRC = "${configHome}/irb/irbrc";

    # NPM / PNPM
    NPM_CONFIG_USERCONFIG = "${configHome}/npm/npmrc";
    PNPM_HOME = "${dataHome}/pnpm";

    # Password Store
    PASSWORD_STORE_DIR = "${dataHome}/pass";

    # Python / Pip
    PYTHON_HISTORY = "${dataHome}/python/history";

    # Wine
    WINEPREFIX = "${dataHome}/wine";
  };
in {
  options.desktop.xdg = {
    enable = mkBoolOpt true "Whether to enable XDG base directory support";
  };

  config = mkIf cfg.enable {
    home = {
      sessionVariables = sessionVariables;
      sessionPath = [
        "~/.local/bin"
        "${sessionVariables.ASDF_DATA_DIR}/bin"
        "${sessionVariables.ASDF_DATA_DIR}/shims"
        "${sessionVariables.CARGO_HOME}/bin"
      ];
    };
    xdg = {
      enable = true;
      autostart.readOnly = true;
      cacheHome = "${config.home.homeDirectory}/.local/cache";
      userDirs = mkIf pkgs.stdenv.hostPlatform.isLinux {
        enable = true;
        createDirectories = true;
        extraConfig = {
          XDG_SCREENSHOTS_DIR = "${config.xdg.userDirs.pictures}/screenshots";
        };
      };
    };
  };
}
