{
  lib,
  config,
  ...
}:
with lib; let
  gtk = config.desktop.addons.gtk;
in {
  config = mkIf (config.services.flatpak.packages != []) {
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
  };
}
