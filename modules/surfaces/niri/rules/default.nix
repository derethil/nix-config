{self, ...}: {
  flake.modules.homeManager.niri = let
    inherit
      (self.lib.niri-rules)
      workspaceRule
      fullscreenRule
      floatRule
      sizedFloatRule
      tileRule
      widthRule
      hideRule
      ;
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
      # Global defaults
      {
        clip-to-geometry = true;
        geometry-corner-radius = [8 8 8 8];
      }

      # Workspace assignments
      (workspaceRule 1 ["^firefox$" "^chromium$"])
      (workspaceRule 2 ["^discord$" "^vesktop$" ".*Mattermost.*" "^zoom$"])
      (workspaceRule 3 ["^bruno$" "^obsidian$"])
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
      (workspaceRule 5 [".*[sS]potify.*" ".*stremio.*"])

      # Floating and tiling overrides
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
      (tileRule "^[mM]inecraft.*$")
      (sizedFloatRule ".*qalculate.*" 1100 800)
      (sizedFloatRule "yazi" 800 720)

      # Steam notification toasts float in the bottom-right corner
      {
        match._props = {
          app-id = "^steam$";
          title._raw = ''r#"^notificationtoasts_\d+_desktop$"#'';
        };
        default-floating-position._props = {
          x = 10;
          y = 10;
          relative-to = "bottom-right";
        };
      }

      # Fullscreen
      (fullscreenRule [
        ".*[mM]inecraft.*"
        "^.*\\.exe$"
        "^steam_app_[1-9][0-9]*$"
        ".*gamescope.*"
        "^org.vinegarhq.Sober$"
      ])

      # Column widths
      # Steam title filter prevents catching the friends-list popup.
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

      # Screen capture exclusions
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
