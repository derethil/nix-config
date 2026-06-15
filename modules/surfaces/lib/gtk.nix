{self, ...}: {
  flake.modules.nixos.gtk = {
    programs.dconf.enable = true;
  };

  flake.modules.homeManager.gtk = {
    config,
    pkgs,
    lib,
    ...
  }: let
    inherit (lib) toString mkDefault;

    font = config.font.sansSerif;
    cursor = config.home.pointerCursor;
    gtkCfg = config.gtk;
  in {
    imports = [self.modules.generic.fonts-options];

    home.pointerCursor = {
      package = mkDefault pkgs.bibata-cursors;
      name = mkDefault "Bibata-Modern-Ice";
      size = mkDefault 24;
      gtk.enable = true;
      x11.enable = true;
      dotIcons.enable = false;
    };

    home.sessionVariables = {
      CURSOR_THEME = cursor.name;
      GTK_THEME = gtkCfg.theme.name;
      XCURSOR_SIZE = toString cursor.size;
      XCURSOR_THEME = cursor.name;
    };

    gtk = {
      enable = true;

      gtk2 = {
        configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
      };

      gtk3 = {
        extraConfig."gtk-application-prefer-dark-theme" = 1;
      };

      gtk4 = {
        extraConfig."AdwStyleManager:color-scheme" = "prefer-dark";
        theme = {
          inherit (gtkCfg.theme) name package;
        };
      };

      font = {
        inherit (font) name package size;
      };

      iconTheme = {
        name = mkDefault "Tela";
        package = mkDefault pkgs.tela-icon-theme;
      };

      theme = {
        name = mkDefault "adw-gtk3-dark";
        package = mkDefault pkgs.adw-gtk3;
      };
    };

    dconf = {
      enable = true;

      settings."org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        cursor-size = cursor.size;
        cursor-theme = cursor.name;
        enable-hot-corners = false;
        font-name = "${font.name} ${toString font.size}";
        gtk-theme = gtkCfg.theme.name;
        icon-theme = gtkCfg.iconTheme.name;
      };
    };

    services.xsettingsd = {
      enable = true;
      settings = {
        "Net/ThemeName" = gtkCfg.theme.name;
        "Net/IconThemeName" = gtkCfg.iconTheme.name;
      };
    };
  };
}
