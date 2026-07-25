{self, ...}: {
  flake.modules.homeManager.niri = let
    inherit
      (self.lib.niri-rules)
      floatRule
      fullscreenRule
      hideRule
      sizedFloatRule
      tileRule
      widthRule
      workspaceRule
      ;
  in {
    imports = with self.modules.homeManager; [
      niri-dynamic-float-rules
      niri-sticky-float-rules
    ];

    surfaces.niri = {
      dynamic-float-rules = [
        {
          height = 600;

          match = [
            {
              app_id = "firefox";
              title = ".*Bitwarden.*";
            }
          ];

          width = 600;
        }
      ];

      sticky-float-rules = [
        {match = [{title = ".*Picture-in-Picture.*";}];}
      ];
    };

    wayland.windowManager.niri.settings.window-rule = [
      # Fullscreen
      (fullscreenRule [
        ".*[mM]inecraft.*"
        ".*gamescope.*"
        "^.*\\.exe$"
        "^org.vinegarhq.Sober$"
        "^steam_app_[1-9][0-9]*$"
      ])
      # Screen capture exclusions
      (hideRule [
        {
          appId = "^firefox$";
          title = "Extension:.*Bitwarden.*";
        }
        {
          appId = "^obsidian$";
          title = ".*";
        }
      ])
      (sizedFloatRule ".*qalculate.*" 1100 800)
      (sizedFloatRule "yazi" 800 720)
      (tileRule "^[mM]inecraft.*$")
      (widthRule [
        ".*[s|S]potify.*$"
        "^Ubisoft Connect"
        "^org.prismlauncher.PrismLauncher$"
      ] {proportion = 2.0 / 3.0;})
      # Workspace assignments
      (workspaceRule 1 ["^chromium$" "^firefox$"])
      (workspaceRule 2 [".*Mattermost.*" "^discord$" "^vesktop$" "^zoom$"])
      (workspaceRule 3 ["^bruno$" "^obsidian$"])
      (workspaceRule 4 [
        ".*[mM]inecraft.*"
        ".*gamescope.*"
        "^.*\\.exe$"
        "^[Ss]team$"
        "^heroic$"
        "^org.prismlauncher.PrismLauncher$"
        "^org.vinegarhq.Sober$"
        "^steam_app_[0-9]+$"
      ])
      (workspaceRule 5 [".*[sS]potify.*" ".*stremio.*"])
      # Global defaults
      {
        clip-to-geometry = true;
        geometry-corner-radius = [8 8 8 8];
      }
      # Column widths
      # Steam title filter prevents catching the friends-list popup.
      {
        default-column-width.proportion = 2.0 / 3.0;

        match._props = {
          app-id._raw = ''r#"^[Ss]team$"#'';
          title = "^[Ss]team$";
        };
      }
      # Steam notification toasts float in the bottom-right corner
      {
        default-floating-position._props = {
          relative-to = "bottom-right";
          x = 10;
          y = 10;
        };

        match._props = {
          app-id = "^steam$";
          title._raw = ''r#"^notificationtoasts_\d+_desktop$"#'';
        };
      }
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
    ];
  };
}
