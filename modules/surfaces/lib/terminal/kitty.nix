{self, ...}: {
  flake.modules.homeManager.kitty = {
    config,
    lib,
    ...
  }: let
    inherit (lib) mkOrder mkOverride;
    priority = 200;
  in {
    imports = [self.modules.homeManager.terminal-options];

    config = {
      programs.kitty = {
        enable = true;

        settings = {
          background = "#282828";
          background_opacity = "1.0";
          bold_font = "${config.font.monospace.name} Bold";
          bold_italic_font = "${config.font.monospace.name} Bold Italic";
          color0 = "#1d2021";
          color1 = "#ea6962";
          color10 = "#a9b665";
          color11 = "#d8a657";
          color12 = "#7daea3";
          color13 = "#d3869b";
          color14 = "#89b482";
          color15 = "#d4be98";
          color2 = "#a9b665";
          color3 = "#d8a657";
          color4 = "#7daea3";
          color5 = "#d3869b";
          color6 = "#89b482";
          color7 = "#d4be98";
          color8 = "#eddeb5";
          color9 = "#ea6962";
          copy_on_select = "clipboard";
          font_family = "${config.font.monospace.name} ${config.font.monospace.style}";
          font_size = config.font.monospace.size;
          foreground = "#d4be98";
          input_delay = 3;
          italic_font = "${config.font.monospace.name} SemiBold Italic";
          mouse_hide_wait = 3.0;
          repaint_delay = 10;
          selection_background = "#d4be98";
          selection_foreground = "#3c3836";
          sync_to_monitor = "yes";
          window_padding_width = 6;
        };
      };

      terminal = {
        commands = {
          base = mkOverride priority ["kitty"];
          withTmux = mkOverride priority ["kitty" "-e" "tmux" "new-session" "-As" "base"];
        };

        desktopFiles = mkOrder priority ["kitty.desktop"];
      };
    };
  };
}
