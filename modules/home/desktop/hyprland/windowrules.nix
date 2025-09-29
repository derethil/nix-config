{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
with lib.glace; let
  cfg = config.glace.desktop.hyprland;
in {
  config = mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      settings.windowrule = [
        # Suppress Events
        "suppressevent maximize, class:.*"
        "suppressevent activatefocus, class:Steam"

        # Fix Steam Flickering
        "stayfocused, title:^()$,class:^(steam)$"
        "minsize 1 1, title:^()$,class:^(steam)$"

        # Default Workspaces
        "workspace 1, class:firefox"
        "workspace 1, class:chromium"

        "workspace 2, class:discord"
        "workspace 2, class:Mattermost"

        "workspace 3, class:Insomnia"
        "workspace 3, class:obsidian"

        "workspace 4, class:^([Ss]team)$, title:^([Ss]team)$"
        "workspace 4, class:^(steam_app_[0-9]+)$"
        "workspace 4, class:heroic"
        "workspace 4, class:GDLauncher"
        "workspace 4, class:^(m|M)(inecraft.*)$"

        "workspace 5, title:.*Spotify.*"

        # Float Management
        "float,title:.*(b|B)luetooth.*"
        "minsize 800 562.5,title:.*(b|B)luetooth.*"

        "float,class:pavucontrol"
        "size 50% 60%,class:pavucontrol"

        "float,class:zenity"

        "tile,class:^(m|M)(inecraft.*)$"

        "float,title:^(Friends List)$,class:steam"

        # Fullscreen Management
        "fullscreen,class:^(m|M)(inecraft.*)$"
        "fullscreen,class:^(steam_app_[0-9]+)$"
      ];
    };
  };
}
