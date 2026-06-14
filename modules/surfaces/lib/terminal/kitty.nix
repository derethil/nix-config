{self, ...}: {
  flake.modules.homeManager.kitty = {
    lib,
    config,
    ...
  }: let
    inherit (lib) mkOrder mkOverride;
    priority = 200;
  in {
    imports = [self.modules.homeManager.terminal-options];

    config = {
      terminal.desktopFiles = mkOrder priority ["kitty.desktop"];
      terminal.commands = {
        base = mkOverride priority ["kitty"];
        withTmux = mkOverride priority ["kitty" "-e" "tmux" "new-session" "-As" "base"];
      };

      programs.kitty = {
        enable = true;
        settings = {
          font_family = "${config.font.monospace.name} ${config.font.monospace.style}";
          bold_font = "${config.font.monospace.name} Bold";
          italic_font = "${config.font.monospace.name} SemiBold Italic";
          bold_italic_font = "${config.font.monospace.name} Bold Italic";
          font_size = config.font.monospace.size;

          window_padding_width = 6;
          background_opacity = "1.0";

          foreground = "#d4be98";
          background = "#282828";
          selection_foreground = "#3c3836";
          selection_background = "#d4be98";

          color0 = "#1d2021";
          color8 = "#eddeb5";
          color1 = "#ea6962";
          color9 = "#ea6962";
          color2 = "#a9b665";
          color10 = "#a9b665";
          color3 = "#d8a657";
          color11 = "#d8a657";
          color4 = "#7daea3";
          color12 = "#7daea3";
          color5 = "#d3869b";
          color13 = "#d3869b";
          color6 = "#89b482";
          color14 = "#89b482";
          color7 = "#d4be98";
          color15 = "#d4be98";

          mouse_hide_wait = 3.0;
          copy_on_select = "clipboard";
          repaint_delay = 10;
          input_delay = 3;
          sync_to_monitor = "yes";
        };
      };
    };
  };
}
