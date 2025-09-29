{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  gtk = config.desktop.addons.gtk;
  enable = (config.services.flatpak.packages != []) && (pkgs.stdenv.hostPlatform.isLinux);
in {
  config = mkIf enable {
    services.flatpak = {
      enable = true;
      update.auto = {
        enable = true;
        onCalendar = "weekly";
      };
      overrides = {
        global = {
          # Force Wayland by default
          Context.sockets = ["wayland" "!x11" "!fallback-x11"];
          Environment = {
            GTK_THEME = mkIf gtk.enable gtk.theme.name;
          };
        };
      };
    };

    system.impermanence.extraDirectories = mkIf config.system.impermanence.enable [
      "/var/lib/flatpak"
      "/var/cache/flatpak"
    ];
  };
}
