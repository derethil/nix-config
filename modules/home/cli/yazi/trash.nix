{
  config,
  lib,
  ...
}: let
  cfg = config.glace.cli.yazi;
  flavor = "yazi-trash";
  mkYaziSymlink = path: config.lib.file.mkOutOfStoreSymlink "${config.xdg.configHome}/yazi/${path}";
in
  lib.mkIf (cfg.enable && cfg.trash.enable) {
    #
    # NOTE: if a need ever arises for another desktop entry, this disparate config logic could be pretty easily refactored to be a reusable lib function

    xdg.configFile."${flavor}/yazi.toml".text = ''
      [mgr]
      ratio = [0, 1, 0]
      sort_dir_first = true
      linemode = "none"
      show_hidden = true
      show_symlink = true
    '';

    xdg.configFile."${flavor}/init.lua".source = mkYaziSymlink "init.lua";
    xdg.configFile."${flavor}/keymap.toml".source = mkYaziSymlink "keymap.toml";
    xdg.configFile."${flavor}/theme.toml".source = mkYaziSymlink "theme.toml";
    xdg.configFile."${flavor}/plugins".source = mkYaziSymlink "plugins";
    xdg.configFile."${flavor}/flavors".source = mkYaziSymlink "flavors";

    glace.desktop.xdg.mimeapps.default."x-scheme-handler/trash" = ["${flavor}.desktop"];

    xdg.desktopEntries.${flavor} = {
      name = "Trash - Yazi";
      icon = "trash";
      genericName = "Trash";
      comment = "Open the trash in Yazi file manager";
      exec = "xdg-terminal-exec-wrapped --app-id yazi env YAZI_CONFIG_HOME=${config.xdg.configHome}/${flavor} yazi ${config.xdg.dataHome}/Trash/files";
      type = "Application";
      categories = ["System" "FileTools" "FileManager"];
      mimeType = ["x-scheme-handler/trash"];
    };
  }
