{
  inputs,
  self,
  ...
}: {
  flake-file.inputs.yazi-gruvbox-dark = {
    url = "github:bennyyip/gruvbox-dark.yazi";
    flake = false;
  };

  flake.modules.homeManager.yazi = {
    config,
    lib,
    pkgs,
    ...
  }: let
    inherit (lib) mkMerge mkIf getExe;
    inherit (pkgs.stdenv.hostPlatform) isLinux;
  in {
    imports = [
      self.modules.homeManager.xdg-terminal-exec
    ];

    config = mkMerge [
      {
        programs.yazi = {
          enable = true;
          shellWrapperName = "yy";

          enableBashIntegration = config.programs.bash.enable;
          enableFishIntegration = config.programs.fish.enable;
          enableZshIntegration = config.programs.zsh.enable;
          enableNushellIntegration = config.programs.nushell.enable;

          flavors.gruvbox-dark = inputs.yazi-gruvbox-dark;
          theme.flavor.dark = "gruvbox-dark";

          settings.mgr = {
            ratio = [2 3 3];
            sort_dir_first = true;
            linemode = "none";
            show_hidden = true;
            show_symlink = true;
          };
        };
      }

      (mkIf isLinux {
        programs.yazi.keymap.mgr.prepend_keymap = [
          {
            on = "<C-n>";
            run = ''shell -- ${getExe pkgs.dragon-drop} -x -T -i -s 256 "$0"'';
          }
        ];

        xdg.desktopEntries.yazi = {
          name = "Yazi";
          icon = "yazi";
          genericName = "File Manager";
          comment = "Blazing fast terminal file manager written in Rust, based on async I/O";
          exec = "${getExe pkgs.xdg-terminal-exec} --app-id=yazi yazi %u";
          type = "Application";
          categories = ["System" "FileTools" "FileManager"];
          mimeType = ["inode/directory"];
        };

        xdg.configFile."xdg-desktop-portal-termfilechooser/config".source = (pkgs.formats.ini {}).generate "termchooser" {
          filechooser = {
            cmd = "${pkgs.xdg-desktop-portal-termfilechooser}/share/xdg-desktop-portal-termfilechooser/yazi-wrapper.sh";
            default_dir = "$HOME";
            save_mode = "suggested";
            env = "TERMCMD='${getExe pkgs.xdg-terminal-exec} --app-id=yazi'";
          };
        };
      })
    ];
  };
}
