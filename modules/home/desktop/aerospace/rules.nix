{
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.desktop.aerospace;

  mkAppRule = appid: commands: {
    run = commands;
    "if" = {app-id = appid;};
  };

  mkTitleRule = title: commands: {
    run = commands;
    "if" = {window-title-regex-substring = title;};
  };
in {
  config = mkIf cfg.enable {
    programs.aerospace.userSettings = {
      on-window-detected = [
        # Float rules
        (mkAppRule "com.apple.systempreferences" "layout floating")
        (mkAppRule "com.apple.ActivityMonitor" "layout floating")
        (mkAppRule "com.apple.Finder" "layout floating")
        (mkTitleRule "Bitwarden" "layout floating")

        # Workspace assignment rules
        (mkAppRule "org.nixos.Firefox" "move-node-to-workspace 1")
        (mkAppRule "org.alacritty" "move-node-to-workspace 2")
        (mkAppRule "com.hnc.Discord" "move-node-to-workspace 3")
        (mkAppRule "Mattermost.Desktop" "move-node-to-workspace 3")
        (mkAppRule "com.apple.MobileSMS" "move-node-to-workspace 3")
        (mkAppRule "com.usebruno.app" "move-node-to-workspace 4")
        (mkAppRule "md.obsidian" "move-node-to-workspace 4")
        (mkAppRule "com.spotify.client" "move-node-to-workspace 4")
        (mkAppRule "org.gorilladevs.GDLauncher" "move-node-to-workspace 5")
        (mkAppRule "com.smartcodeltd.stremio" "move-node-to-workspace 5")
        (mkAppRule "com.valvesoftware.steam" "move-node-to-workspace 5")
      ];
    };
  };
}
