{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.internal) mkBoolOpt;
  cfg = config.apps.alacritty;
  monoFont = config.system.fonts.mono;
in {
  options.apps.alacritty = {
    enable = mkBoolOpt false "Whether to enable the Alacritty terminal.";
  };

  config = mkIf cfg.enable {
    programs.alacritty = {
      enable = true;
      settings = {
        general = {
          live_config_reload = true;
        };
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
            family = monoFont.name;
            style = monoFont.style;
          };
          bold = {
            family = monoFont.name;
            style = "Bold";
          };
          italic = {
            family = monoFont.name;
            style = "SemiBold Italic";
          };
          bold_italic = {
            family = monoFont.name;
            style = "Bold Italic";
          };
          size = monoFont.size;
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
        mouse = {
          hide_when_typing = true;
        };
        selection = {
          save_to_clipboard = true;
        };
      };
    };
  };
}
