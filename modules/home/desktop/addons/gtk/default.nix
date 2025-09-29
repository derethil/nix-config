{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf types;
  inherit (lib.glace) mkBoolOpt mkOpt;
  cfg = config.glace.desktop.addons.gtk;
in {
  options.glace.desktop.addons.gtk = {
    enable = mkBoolOpt false "Whether to enable GTK configuration.";

    cursor = {
      package = mkOpt types.package pkgs.bibata-cursors "The cursor package to use.";
      name = mkOpt types.str "Bibata-Modern-Ice" "The cursor theme to use.";
      size = mkOpt types.int 24 "The cursor size.";
    };

    font = {
      name = mkOpt types.str "Inter" "The font name to use.";
      package = mkOpt types.package (pkgs.google-fonts.override {fonts = ["Inter"];}) "The font package to use.";
      size = mkOpt types.int 9 "The font size.";
    };

    icon-theme = {
      name = mkOpt types.str "MoreWaita" "The icon theme name to use.";
      package = mkOpt types.package pkgs.morewaita-icon-theme "The icon theme package to use.";
    };

    theme = {
      name = mkOpt types.str "adw-gtk3-dark" "The GTK theme name to use.";
      package = mkOpt types.package pkgs.adw-gtk3 "The GTK theme package to use.";
    };
  };

  config = mkIf cfg.enable {
    home.sessionVariables = {
      CURSOR_THEME = cfg.cursor.name;
      GTK_THEME = cfg.theme.name;
      XCURSOR_SIZE = "${toString cfg.cursor.size}";
      XCURSOR_THEME = cfg.cursor.name;
    };

    home.pointerCursor = {
      inherit (cfg.cursor) name;
      inherit (cfg.cursor) package;
      inherit (cfg.cursor) size;
      gtk.enable = true;
      x11.enable = true;
    };

    dconf = {
      enable = true;
      settings = {
        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
          cursor-size = cfg.cursor.size;
          cursor-theme = cfg.cursor.name;
          enable-hot-corners = false;
          font-name = "${cfg.font.name} ${toString cfg.font.size}";
          gtk-theme = cfg.theme.name;
          icon-theme = cfg.icon-theme.name;
        };
      };
    };

    gtk = {
      enable = true;
      gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
      gtk3.extraConfig = {"gtk-application-prefer-dark-theme" = 1;};
      gtk4.extraConfig = {"AdwStyleManager:color-scheme" = "prefer-dark";};
      font = {
        inherit (cfg.font) name;
        inherit (cfg.font) package;
        inherit (cfg.font) size;
      };
      iconTheme = {
        inherit (cfg.icon-theme) name;
        inherit (cfg.icon-theme) package;
      };
      theme = {
        inherit (cfg.theme) name;
        inherit (cfg.theme) package;
      };
    };

    services.xsettingsd = {
      enable = true;
      settings = {
        "Net/ThemeName" = cfg.theme.name;
        "Net/IconThemeName" = cfg.icon-theme.name;
      };
    };
  };
}
