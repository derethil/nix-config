{
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf mkAfter;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.apps.kitty;
  monoFont = config.glace.system.fonts.default.monospace;
in {
  options.glace.apps.kitty = {
    enable = mkBoolOpt false "Whether to enable the Kitty terminal.";
  };

  config = mkIf cfg.enable {
    glace.desktop.xdg.terminal.default = mkAfter ["kitty.desktop"];

    programs.kitty = {
      enable = true;
      settings = {
        # Font configuration
        font_family = "${monoFont.name} ${monoFont.style}";
        bold_font = "${monoFont.name} Bold";
        italic_font = "${monoFont.name} SemiBold Italic";
        bold_italic_font = "${monoFont.name} Bold Italic";
        font_size = monoFont.size;

        # Window layout
        window_padding_width = 6;
        background_opacity = "1.0";

        # Theme
        foreground = "#d4be98";
        background = "#282828";
        selection_foreground = "#3c3836";
        selection_background = "#d4be98";

        # Black
        color0 = "#1d2021";
        color8 = "#eddeb5";

        # Red
        color1 = "#ea6962";
        color9 = "#ea6962";

        # Green
        color2 = "#a9b665";
        color10 = "#a9b665";

        # Yellow
        color3 = "#d8a657";
        color11 = "#d8a657";

        # Blue
        color4 = "#7daea3";
        color12 = "#7daea3";

        # Magenta
        color5 = "#d3869b";
        color13 = "#d3869b";

        # Cyan
        color6 = "#89b482";
        color14 = "#89b482";

        # White
        color7 = "#d4be98";
        color15 = "#d4be98";

        # Mouse
        mouse_hide_wait = 3.0;

        # Clipboard
        copy_on_select = "clipboard";

        # Performance
        repaint_delay = 10;
        input_delay = 3;
        sync_to_monitor = "yes";
      };
    };
  };
}
