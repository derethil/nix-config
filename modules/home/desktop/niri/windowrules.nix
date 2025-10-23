{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.glace.desktop.niri;

  defaultWorkspaceRule = appId: workspace: {
    matches = [{app-id = appId;}];
    open-on-workspace = toString workspace;
    open-focused = true;
  };

  fullscreenRule = appId: {
    matches = [{app-id = appId;}];
    open-fullscreen = true;
    open-focused = true;
  };

  defaultWidthRule = appId: widthConfig: {
    matches = [{app-id = appId;}];
    default-column-width = widthConfig;
  };
in {
  config = mkIf cfg.enable {
    programs.niri.settings.spawn-at-startup = [
      {argv = [(lib.getExe pkgs.glace.niri-dynamic-float-rules)];}
    ];

    programs.niri.settings.window-rules = [
      # Rounded Borders
      {
        clip-to-geometry = true;
        geometry-corner-radius = {
          bottom-left = 8.0;
          bottom-right = 8.0;
          top-left = 8.0;
          top-right = 8.0;
        };
      }

      # Fix Steam Flickering
      {
        matches = [
          {
            app-id = "^steam$";
            title = "^()$";
          }
        ];
        open-focused = true;
        min-width = 1;
        min-height = 1;
      }

      # Default Workspaces
      (defaultWorkspaceRule "^firefox$" 1)
      (defaultWorkspaceRule "^chromium$" 1)

      (defaultWorkspaceRule "^discord$" 2)
      (defaultWorkspaceRule "^Mattermost$" 2)

      (defaultWorkspaceRule "^Insomnia$" 3)
      (defaultWorkspaceRule "^obsidian$" 3)

      (defaultWorkspaceRule "^[Ss]team$" 4)
      (defaultWorkspaceRule "^.*\\.exe$" 4)
      (defaultWorkspaceRule "^steam_app_[0-9]+$" 4)
      (defaultWorkspaceRule "^heroic$" 4)
      (defaultWorkspaceRule "^GDLauncher$" 4)
      (defaultWorkspaceRule "^[mM]inecraft.*$" 4)
      (defaultWorkspaceRule "^org.vinegarhq.Sober$" 4)

      (defaultWorkspaceRule ".*Spotify.*" 5)
      (defaultWorkspaceRule ".*stremio.*" 5)

      # Floating Windows
      {
        matches = [{app-id = "^[mM]inecraft.*$";}];
        open-floating = false;
        tiled-state = true;
      }

      {
        matches = [
          {
            title = "^(Friends List)$";
            app-id = "steam";
          }
        ];
        open-floating = true;
      }

      # Fullscreen Windows
      (fullscreenRule "^[mM]inecraft.*$")
      (fullscreenRule "^.*\\.exe$")
      (fullscreenRule "^steam_app_[0-9]+$")
      (fullscreenRule "^org.vinegarhq.Sober$")

      # Default Column Widths
      (defaultWidthRule "^[Ss]team$" {proportion = 2. / 3.;})
      (defaultWidthRule ".*Spotify.*$" {proportion = 2. / 3.;})
      (defaultWidthRule "^GDLauncher$" {proportion = 2. / 3.;})
    ];
  };
}
