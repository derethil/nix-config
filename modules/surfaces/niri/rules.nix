{self, ...}: {
  flake.modules.homeManager.niri = {...}: let
    appIdMatch = appId: {_props.app-id._raw = ''r#"${appId}"#'';};
    appIdMatches = map appIdMatch;

    workspaceRule = workspace: appIds: {
      match = appIdMatches appIds;
      open-on-workspace = toString workspace;
      open-focused = true;
    };

    fullscreenRule = appIds: {
      match = appIdMatches appIds;
      open-fullscreen = true;
      open-focused = true;
    };

    widthRule = appIds: widthConfig: {
      match = appIdMatches appIds;
      default-column-width = widthConfig;
    };

    hideRule = pairs: {
      match =
        map (p: {
          _props = {
            app-id._raw = ''r#"${p.appId}"#'';
            inherit (p) title;
          };
        })
        pairs;
      block-out-from = "screen-capture";
    };
  in {
    imports = with self.modules.homeManager; [
      niri-sticky-float-rules
      niri-dynamic-float-rules
    ];

    surfaces.niri.dynamic-float-rules = [
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

    surfaces.niri.sticky-float-rules = [
      {match = [{title = ".*Picture-in-Picture.*";}];}
    ];

    wayland.windowManager.niri.settings.window-rule = [
      # Rounded borders
      {
        clip-to-geometry = true;
        geometry-corner-radius = [8 8 8 8];
      }

      # Fix steam flickering
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
      (workspaceRule 1 [
        "^firefox$"
        "^chromium$"
      ])
      (workspaceRule 2 [
        "^discord$"
        "^vesktop$"
        "^Mattermost$"
        "^zoom$"
      ])
      (workspaceRule 3 [
        "^bruno$"
        "^obsidian$"
      ])
      (workspaceRule 4 [
        "^[Ss]team$"
        "^.*\\.exe$"
        "^steam_app_[0-9]+$"
        ".*gamescope.*"
        "^heroic$"
        "^org.prismlauncher.PrismLauncher$"
        ".*[mM]inecraft.*"
        "^org.vinegarhq.Sober$"
      ])
      (workspaceRule 5 [
        ".*[sS]potify.*"
        ".*stremio.*"
      ])

      # Floating Windows — title-only or app-id-only matches collapse into one rule;
      # rules with unique sizing stay separate.
      {
        match = [
          {
            _props = {
              app-id = "steam";
              title = "^(Friends List)$";
            };
          }
          {_props.title = ".*Picture-in-Picture.*";}
        ];
        open-floating = true;
      }

      {
        match._props.app-id = "^[mM]inecraft.*$";
        open-floating = false;
        tiled-state = true;
      }
      {
        match._props.app-id = ".*qalculate.*";
        open-floating = true;
        default-window-height.fixed = 800;
        default-column-width.fixed = 1100;
      }
      {
        match._props.app-id = "yazi";
        open-floating = true;
        default-window-height.fixed = 720;
        default-column-width.fixed = 800;
      }

      # Fullscreen Windows
      (fullscreenRule [
        ".*[mM]inecraft.*"
        "^.*\\.exe$"
        "^steam_app_[1-9][0-9]*$"
        ".*gamescope.*"
        "^org.vinegarhq.Sober$"
      ])

      # Default Column Widths
      # Steam keeps its title filter so it doesn't catch the friends-list popup.
      {
        match._props = {
          app-id._raw = ''r#"^[Ss]team$"#'';
          title = "^[Ss]team$";
        };
        default-column-width.proportion = 2.0 / 3.0;
      }
      (widthRule [
        "^Ubisoft Connect"
        ".*[s|S]potify.*$"
        "^org.prismlauncher.PrismLauncher$"
      ] {proportion = 2.0 / 3.0;})

      # Screen Capture Exclusions
      (hideRule [
        {
          appId = "^obsidian$";
          title = ".*";
        }
        {
          appId = "^firefox$";
          title = "Extension:.*Bitwarden.*";
        }
      ])
    ];
  };
}
