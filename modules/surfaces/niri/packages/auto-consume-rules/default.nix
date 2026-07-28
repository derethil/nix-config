{lib, ...}: {
  flake.modules.homeManager.niri-auto-consume-rules = {
    config,
    pkgs,
    ...
  }: let
    inherit (lib) filterAttrs getExe mkOption types;

    matchType = types.submodule {
      options = {
        app_id = mkOption {
          default = null;
          description = "App ID regex pattern to match.";
          type = types.nullOr types.str;
        };

        title = mkOption {
          default = null;
          description = "Window title regex pattern to match.";
          type = types.nullOr types.str;
        };
      };
    };

    ruleType = types.submodule {
      options = {
        direction = mkOption {
          default = "left";
          description = "Which adjacent column to consume the window into: \"left\" or \"right\".";
          type = types.enum ["left" "right"];
        };

        exclude = mkOption {
          default = [];
          description = "List of exclude conditions (OR logic).";
          type = types.listOf matchType;
        };

        match = mkOption {
          default = [];
          description = "List of match conditions (OR logic).";
          type = types.listOf matchType;
        };

        tabbed = mkOption {
          default = false;
          description = "Set default-column-display to tabbed for matching windows via a niri window-rule.";
          type = types.bool;
        };
      };
    };

    rules = config.surfaces.niri.auto-consume-rules;

    toNiriMatch = m: {
      _props = filterAttrs (_: v: v != null) {
        app-id = m.app_id;
        title = m.title;
      };
    };

    tabbedWindowRules =
      map (r: {
        default-column-display = "tabbed";
        match = map toNiriMatch (lib.filter (m: m.app_id != null || m.title != null) r.match);
      }) (lib.filter (r: r.tabbed) rules);
  in {
    options.surfaces.niri.auto-consume-rules = mkOption {
      default = [];

      description = ''
        Auto-consume rules. Each rule is checked against newly opened windows;
        on first match the daemon consumes the window into an adjacent column
        (left or right) and optionally toggles tabbed display on that column.
      '';

      type = types.listOf ruleType;
    };

    config = lib.mkIf (rules != []) {
      wayland.windowManager.niri.settings = {
        spawn-at-startup = [
          {
            _args = [
              "${getExe pkgs.internal.niri-auto-consume-rules} -rules ${config.xdg.configHome}/niri/auto-consume-rules.json"
            ];
          }
        ];

        window-rule = tabbedWindowRules;
      };

      xdg.configFile."niri/auto-consume-rules.json".source =
        pkgs.writeText "auto-consume-rules.json" (builtins.toJSON rules);
    };
  };

  perSystem = {
    pkgs,
    system,
    ...
  }:
    lib.optionalAttrs (lib.elem system lib.platforms.linux) {
      packages.niri-auto-consume-rules = pkgs.buildGoModule {
        pname = "niri-auto-consume-rules";
        src = ./.;
        vendorHash = null;
        version = "0.1.0";

        meta = {
          description = "Auto-consume window rules for niri compositor";
          mainProgram = "niri-auto-consume-rules";
        };
      };
    };
}
