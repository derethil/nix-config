{self, ...}: {
  flake.modules = {
    nixos.gtk.programs.dconf.enable = true;

    homeManager.gtk = {
      config,
      lib,
      pkgs,
      ...
    }: let
      inherit (lib) mkDefault;

      font = config.font.sansSerif;
      cursor = config.home.pointerCursor;
      gtkCfg = config.gtk;
    in {
      imports = [self.modules.generic.fonts-options];

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

      gtk = {
        enable = true;

        font = {
          inherit (font) name package size;
        };

        gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
        gtk3.extraConfig."gtk-application-prefer-dark-theme" = 1;

        gtk4 = {
          extraConfig."AdwStyleManager:color-scheme" = "prefer-dark";

          theme = {
            inherit (gtkCfg.theme) name package;
          };
        };

        iconTheme = {
          package = mkDefault pkgs.tela-icon-theme;
          name = mkDefault "Tela";
        };

        theme = {
          package = mkDefault pkgs.adw-gtk3;
          name = mkDefault "adw-gtk3-dark";
        };
      };

      home = {
        pointerCursor = {
          package = mkDefault pkgs.bibata-cursors;
          dotIcons.enable = false;
          gtk.enable = true;
          name = mkDefault "Bibata-Modern-Ice";
          size = mkDefault 24;
          x11.enable = true;
        };

        sessionVariables = {
          CURSOR_THEME = cursor.name;
          GTK_THEME = gtkCfg.theme.name;
          XCURSOR_SIZE = toString cursor.size;
          XCURSOR_THEME = cursor.name;
        };
      };

      services.xsettingsd = {
        enable = true;

        settings = {
          "Net/IconThemeName" = gtkCfg.iconTheme.name;
          "Net/ThemeName" = gtkCfg.theme.name;
        };
      };
    };
  };
}
