{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
with internal; let
  cfg = config.desktop.addons.gtk;
in {
  options.desktop.addons.gtk = {
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

    gtk = {
      enable = true;
      gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
      gtk3.extraConfig = {"gtk-application-prefer-dark-theme" = 1;};
      gtk4.extraConfig = {"gtk-application-prefer-dark-theme" = 1;};
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
