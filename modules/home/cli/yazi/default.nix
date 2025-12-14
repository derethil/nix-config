{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: let
  inherit (lib) mkIf getExe;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.cli.yazi;
in {
  options.glace.cli.yazi = {
    enable = mkBoolOpt false "Whether to enable yazi file manager.";
  };

  config = mkIf cfg.enable {
    programs.yazi = {
      enable = true;
      enableFishIntegration = true;

      flavors = {
        gruvbox-dark = inputs.yazi-gruvbox-dark;
      };

      theme.flavor = {
        dark = "gruvbox-dark";
      };

      settings = {
        mgr = {
          ratio = [2 3 3];
          sort_dir_first = true;
          linemode = "none";
          show_hidden = true;
          show_symlink = true;
        };
      };

      keymap = {
        mgr = {
          prepend_keymap = [
            {
              on = "<C-n>";
              run = ''shell -- ${getExe pkgs.dragon-drop} -x -T -s 128 "$0"'';
            }
          ];
        };
      };
    };

    xdg.desktopEntries.yazi = {
      name = "Yazi";
      icon = "yazi";
      genericName = "File Manager";
      comment = "Blazing fast terminal file manager written in Rust, based on async I/O";
      exec = "xdg-terminal-exec -a yazi yazi %u";
      type = "Application";
      categories = ["System" "FileTools" "FileManager"];
      mimeType = ["inode/directory"];
    };
  };
}
