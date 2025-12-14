{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: let
  inherit (lib) mkIf getExe types;
  inherit (lib.glace) mkBoolOpt mkOpt;
  cfg = config.glace.cli.yazi;
in {
  options.glace.cli.yazi = {
    enable = mkBoolOpt false "Whether to enable yazi file manager.";
    portal = {
      enable = mkBoolOpt true "Whether to use  yazi as the default file picker portal.";
      terminal = mkOpt (types.nullOr types.str) null "The terminal emulator command to use for the portal. If null, uses xdg-terminal-exec from glace.desktop.xdg.";
    };
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
              run = ''shell -- ${getExe pkgs.dragon-drop} -x -T -i -s 256 "$0"'';
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

    xdg.configFile."xdg-desktop-portal-termfilechooser/config" = mkIf cfg.portal.enable {
      source = (pkgs.formats.ini {}).generate "termchooser" {
        filechooser = {
          cmd = "${pkgs.xdg-desktop-portal-termfilechooser}/share/xdg-desktop-portal-termfilechooser/yazi-wrapper.sh";
          default_dir = "$HOME";
          env = "TERMCMD='${
            if cfg.portal.terminal != null
            then cfg.portal.terminal
            else "${getExe config.xdg.terminal-exec.package} -a yazi"
          }'";
        };
      };
    };

    assertions = [
      {
        assertion = cfg.portal.enable -> (config.glace.desktop.xdg.enable && (config.glace.desktop.xdg.terminal.default != null));
        message = "Option `glace.cli.yazi.portal.enable` requires `glace.desktop.xdg.enable` and `glace.desktop.xdg.terminal.default` to be set.";
      }
    ];
  };
}
