# Dynamic float daemon — watches niri's event stream and floats windows the
# first time they match a configured rule. Useful for windows whose title or
# app_id only settles after launch (Bitwarden inside Firefox is the canonical
# case), which static niri window-rules can't catch.
{lib, ...}: {
  flake.modules.homeManager.niri-dynamic-float-rules = {
    config,
    pkgs,
    ...
  }: let
    inherit (lib) getExe mkOption types;

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
        exclude = mkOption {
          default = [];
          description = "List of exclude conditions (OR logic).";
          type = types.listOf matchType;
        };

        height = mkOption {
          default = null;
          description = "Fixed height to apply to the window after floating.";
          type = types.nullOr types.int;
        };

        match = mkOption {
          default = [];
          description = "List of match conditions (OR logic).";
          type = types.listOf matchType;
        };

        width = mkOption {
          default = null;
          description = "Fixed width to apply to the window after floating.";
          type = types.nullOr types.int;
        };
      };
    };

    rules = config.surfaces.niri.dynamic-float-rules;
  in {
    options.surfaces.niri.dynamic-float-rules = mkOption {
      default = [];

      description = ''
        Dynamic float rules. Each rule is checked against newly seen windows;
        on first match the daemon floats the window, optionally resizes it,
        and centers it. Useful for windows whose title or app_id only
        settles after launch.
      '';

      type = types.listOf ruleType;
    };

    config = lib.mkIf (rules != []) {
      wayland.windowManager.niri.settings.spawn-at-startup = [
        {
          _args = [
            "${getExe pkgs.internal.niri-dynamic-float-rules} -rules ${config.xdg.configHome}/niri/dynamic-float-rules.json"
          ];
        }
      ];

      xdg.configFile."niri/dynamic-float-rules.json".source =
        pkgs.writeText "dynamic-float-rules.json" (builtins.toJSON rules);
    };
  };

  perSystem = {
    pkgs,
    system,
    ...
  }:
    lib.optionalAttrs (lib.elem system lib.platforms.linux) {
      packages.niri-dynamic-float-rules = pkgs.buildGoModule {
        pname = "niri-dynamic-float-rules";
        src = ./.;
        vendorHash = null;
        version = "0.1.0";

        meta = {
          description = "Dynamic float window rules for niri compositor";
          mainProgram = "niri-dynamic-float-rules";
        };
      };
    };
}
