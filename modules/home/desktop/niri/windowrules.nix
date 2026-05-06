{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.glace.desktop.niri;

  hideWindowRule = appId: title: {
    match._props = {
      app-id._raw = ''r#"${appId}"#'';
      title = title;
    };
    block-out-from = "screen-capture";
  };

  defaultWorkspaceRule = appId: workspace: {
    match._props = {app-id._raw = ''r#"${appId}"#'';};
    open-on-workspace = toString workspace;
    open-focused = true;
  };

  fullscreenRule = appId: {
    match._props = {app-id._raw = ''r#"${appId}"#'';};
    open-fullscreen = true;
    open-focused = true;
  };

  defaultWidthRule = appId: title: widthConfig: {
    match._props = {
      app-id._raw = ''r#"${appId}"#'';
      title = title;
    };
    default-column-width = widthConfig;
  };

  defaultWidthRule' = appId: widthConfig: defaultWidthRule appId ".*" widthConfig;
in {
  config = mkIf cfg.enable {
    wayland.windowManager.niri.settings.window-rule = [
      # Rounded Borders
      {
        clip-to-geometry = true;
        geometry-corner-radius = [8 8 8 8];
      }

      # Fix Steam Flickering
      {
        match._props = {
          app-id = "^steam$";
          title = "^()$";
        };
        open-focused = true;
        min-width = 1;
        min-height = 1;
      }

      # Default Workspaces
      (defaultWorkspaceRule "^firefox$" 1)
      (defaultWorkspaceRule "^chromium$" 1)

      (defaultWorkspaceRule "^discord$" 2)
      (defaultWorkspaceRule "^vesktop$" 2)
      (defaultWorkspaceRule "^Mattermost$" 2)
      (defaultWorkspaceRule "^zoom$" 2)

      (defaultWorkspaceRule "^bruno$" 3)
      (defaultWorkspaceRule "^obsidian$" 3)

      (defaultWorkspaceRule "^[Ss]team$" 4)
      (defaultWorkspaceRule "^.*\\.exe$" 4)
      (defaultWorkspaceRule "^steam_app_[0-9]+$" 4)
      (defaultWorkspaceRule ".*gamescope.*" 4)
      (defaultWorkspaceRule "^heroic$" 4)
      (defaultWorkspaceRule "^org.prismlauncher.PrismLauncher$" 4)
      (defaultWorkspaceRule ".*[mM]inecraft.*" 4)
      (defaultWorkspaceRule "^org.vinegarhq.Sober$" 4)

      (defaultWorkspaceRule ".*[sS]potify.*" 5)
      (defaultWorkspaceRule ".*stremio.*" 5)

      # Floating Windows
      {
        match._props = {app-id = "^[mM]inecraft.*$";};
        open-floating = false;
        tiled-state = true;
      }
      {
        match._props = {
          title = "^(Friends List)$";
          app-id = "steam";
        };
        open-floating = true;
      }
      {
        match._props = {app-id = ".*qalculate.*";};
        open-floating = true;
        default-window-height = {fixed = 800;};
        default-column-width = {fixed = 1100;};
      }
      {
        match._props = {title = ".*Picture-in-Picture.*";};
        open-floating = true;
      }
      {
        match._props = {app-id = "yazi";};
        open-floating = true;
        default-window-height = {fixed = 720;};
        default-column-width = {fixed = 800;};
      }

      # Fullscreen Windows
      (fullscreenRule ".*[mM]inecraft.*")
      (fullscreenRule "^.*\\.exe$")
      (fullscreenRule "^steam_app_[1-9][0-9]*$")
      (fullscreenRule ".*gamescope.*")
      (fullscreenRule "^org.vinegarhq.Sober$")

      # Default Column Widths
      (defaultWidthRule "^[Ss]team$" "^[Ss]team$" {proportion = 2. / 3.;})
      (defaultWidthRule' "^Ubisoft Connect" {proportion = 2. / 3.;})
      (defaultWidthRule' ".*[s|S]potify.*$" {proportion = 2. / 3.;})
      (defaultWidthRule' "^org.prismlauncher.PrismLauncher$" {proportion = 2. / 3.;})

      # Screen Capture Exclusions
      (hideWindowRule "^obsidian$" ".*")
      (hideWindowRule "^firefox$" "Extension:.*Bitwarden.*")
    ];

    # Force float state for windows that set their title after launch (only known case is Bitwarden)
    glace.desktop.niri.dynamic-float-rules = [
      {
        match = [
          {
            title = ".*Bitwarden.*";
            app_id = "firefox";
          }
        ];
        width = 600;
        height = 600;
      }
    ];

    # Script-based pinned windows, see: https://github.com/YaLTeR/niri/issues/932
    glace.desktop.niri.sticky-float-rules = [
      {
        match = [
          {
            title = ".*Picture-in-Picture.*";
          }
        ];
      }
    ];
  };
}
