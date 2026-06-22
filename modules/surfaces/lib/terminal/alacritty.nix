{self, ...}: {
  flake.modules.homeManager.alacritty = {
    pkgs,
    lib,
    config,
    ...
  }: let
    inherit (lib) mkOrder mkOverride mkIf;
    priority = 300;
  in {
    imports = [self.modules.homeManager.terminal-options];

    config = {
      terminal = {
        desktopFiles = mkOrder priority ["Alacritty.desktop"];
        commands = {
          base = mkOverride priority ["alacritty"];
          withTmux = mkOverride priority ["alacritty" "-e" "tmux" "new-session" "-As" "base"];
        };
      };

      programs.alacritty = {
        enable = true;
        settings = {
          general.live_config_reload = true;
          window = {
            padding = {
              x = 6;
              y = 6;
            };
            opacity = 1.0;
            option_as_alt = mkIf pkgs.stdenv.hostPlatform.isDarwin "OnlyLeft";
          };
          font = {
            normal = {
              family = config.font.monospace.name;
              style = config.font.monospace.style;
            };
            bold = {
              family = config.font.monospace.name;
              style = "Bold";
            };
            italic = {
              family = config.font.monospace.name;
              style = "SemiBold Italic";
            };
            bold_italic = {
              family = config.font.monospace.name;
              style = "Bold Italic";
            };
            size = config.font.monospace.size;
          };
          colors = {
            primary = {
              background = "#282828";
              foreground = "#d4be98";
            };
            normal = {
              black = "#1d2021";
              red = "#ea6962";
              green = "#a9b665";
              yellow = "#d8a657";
              blue = "#7daea3";
              magenta = "#d3869b";
              cyan = "#89b482";
              white = "#d4be98";
            };
            bright = {
              black = "#eddeb5";
              red = "#ea6962";
              green = "#a9b665";
              yellow = "#d8a657";
              blue = "#7daea3";
              magenta = "#d3869b";
              cyan = "#89b482";
              white = "#d4be98";
            };
            selection = {
              text = "#3c3836";
              background = "#d4be98";
            };
          };
          mouse.hide_when_typing = true;
          selection.save_to_clipboard = true;
          keyboard = {
            bindings = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin [
              {
                key = "H";
                mods = "Command|Shift";
                chars = builtins.fromJSON ("\"\\u001b[300~\"");
              }
              {
                key = "L";
                mods = "Command|Shift";
                chars = builtins.fromJSON ("\"\\u001b[301~\"");
              }
            ];
          };
        };
      };
    };
  };
}
