{
  self,
  inputs,
  ...
}: {
  flake-file.inputs.yazi-gruvbox-dark = {
    flake = false;
    url = "github:bennyyip/gruvbox-dark.yazi";
  };

  flake.modules.homeManager.yazi = {
    config,
    lib,
    pkgs,
    ...
  }: let
    inherit (lib) getExe mkIf mkMerge;
    inherit (pkgs.stdenv.hostPlatform) isLinux;
  in {
    imports = [
      self.modules.homeManager.xdg-terminal-exec
    ];

    config = mkMerge [
      (mkIf isLinux {
        programs.yazi.keymap.mgr.prepend_keymap = [
          {
            on = "<C-n>";
            run = ''shell -- ${getExe pkgs.dragon-drop} -x -T -i -s 256 "$0"'';
          }
        ];

        xdg = {
          configFile."xdg-desktop-portal-termfilechooser/config".source = (pkgs.formats.ini {}).generate "termchooser" {
            filechooser = {
              cmd = "${pkgs.xdg-desktop-portal-termfilechooser}/share/xdg-desktop-portal-termfilechooser/yazi-wrapper.sh";
              default_dir = "$HOME";
              env = "TERMCMD='${getExe pkgs.xdg-terminal-exec} --app-id=yazi'";
              save_mode = "suggested";
            };
          };

          desktopEntries.yazi = {
            categories = ["FileManager" "FileTools" "System"];
            comment = "Blazing fast terminal file manager written in Rust, based on async I/O";
            exec = "${getExe pkgs.xdg-terminal-exec} --app-id=yazi yazi %u";
            genericName = "File Manager";
            icon = "yazi";
            mimeType = ["inode/directory"];
            name = "Yazi";
            type = "Application";
          };
        };
      })
      {
        programs.yazi = {
          enable = true;
          enableBashIntegration = config.programs.bash.enable;
          enableFishIntegration = config.programs.fish.enable;
          enableNushellIntegration = config.programs.nushell.enable;
          enableZshIntegration = config.programs.zsh.enable;
          flavors.gruvbox-dark = inputs.yazi-gruvbox-dark;

          settings.mgr = {
            linemode = "none";
            ratio = [2 3 3];
            show_hidden = true;
            show_symlink = true;
            sort_dir_first = true;
          };

          shellWrapperName = "yy";
          theme.flavor.dark = "gruvbox-dark";
        };
      }
    ];
  };
}
