{self, ...}: {
  flake.modules.homeManager.alacritty = {
    config,
    lib,
    pkgs,
    ...
  }: let
    inherit (lib) mkIf mkOrder mkOverride;
    priority = 300;
  in {
    imports = [self.modules.homeManager.terminal-options];

    config = {
      programs.alacritty = {
        enable = true;

        settings = {
          colors = {
            bright = {
              black = "#eddeb5";
              blue = "#7daea3";
              cyan = "#89b482";
              green = "#a9b665";
              magenta = "#d3869b";
              red = "#ea6962";
              white = "#d4be98";
              yellow = "#d8a657";
            };

            normal = {
              black = "#1d2021";
              blue = "#7daea3";
              cyan = "#89b482";
              green = "#a9b665";
              magenta = "#d3869b";
              red = "#ea6962";
              white = "#d4be98";
              yellow = "#d8a657";
            };

            primary = {
              background = "#282828";
              foreground = "#d4be98";
            };

            selection = {
              background = "#d4be98";
              text = "#3c3836";
            };
          };

          font = {
            bold = {
              family = config.font.monospace.name;
              style = "Bold";
            };

            bold_italic = {
              family = config.font.monospace.name;
              style = "Bold Italic";
            };

            italic = {
              family = config.font.monospace.name;
              style = "SemiBold Italic";
            };

            normal = {
              family = config.font.monospace.name;
              style = config.font.monospace.style;
            };

            size = config.font.monospace.size;
          };

          general.live_config_reload = true;

          keyboard.bindings = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin [
            {
              key = "H";
              chars = builtins.fromJSON "\"\\u001b[300~\"";
              mods = "Command|Shift";
            }
            {
              key = "L";
              chars = builtins.fromJSON "\"\\u001b[301~\"";
              mods = "Command|Shift";
            }
          ];

          mouse.hide_when_typing = true;
          selection.save_to_clipboard = true;

          window = {
            opacity = 1.0;
            option_as_alt = mkIf pkgs.stdenv.hostPlatform.isDarwin "OnlyLeft";

            padding = {
              x = 6;
              y = 6;
            };
          };
        };
      };

      terminal = {
        commands = {
          base = mkOverride priority ["alacritty"];
          withTmux = mkOverride priority ["-As" "-e" "alacritty" "base" "new-session" "tmux"];
        };

        desktopFiles = mkOrder priority ["Alacritty.desktop"];
      };
    };
  };
}
