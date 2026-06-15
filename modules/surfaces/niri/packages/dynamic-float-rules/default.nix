# Dynamic float daemon — watches niri's event stream and floats windows the
# first time they match a configured rule. Useful for windows whose title or
# app_id only settles after launch (Bitwarden inside Firefox is the canonical
# case), which static niri window-rules can't catch.
{lib, ...}: {
  perSystem = {
    system,
    pkgs,
    ...
  }:
    lib.optionalAttrs (lib.elem system lib.platforms.linux) {
      packages.niri-dynamic-float-rules = pkgs.buildGoModule {
        pname = "niri-dynamic-float-rules";
        version = "0.1.0";
        src = ./.;
        vendorHash = null;
        meta = {
          description = "Dynamic float window rules for niri compositor";
          mainProgram = "niri-dynamic-float-rules";
        };
      };
    };

  flake.modules.homeManager.niri-dynamic-float-rules = {
    config,
    pkgs,
    ...
  }: let
    inherit (lib) mkOption types getExe;

    matchType = types.submodule {
      options = {
        title = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = "Window title regex pattern to match.";
        };
        app_id = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = "App ID regex pattern to match.";
        };
      };
    };

    ruleType = types.submodule {
      options = {
        match = mkOption {
          type = types.listOf matchType;
          default = [];
          description = "List of match conditions (OR logic).";
        };
        exclude = mkOption {
          type = types.listOf matchType;
          default = [];
          description = "List of exclude conditions (OR logic).";
        };
        width = mkOption {
          type = types.nullOr types.int;
          default = null;
          description = "Fixed width to apply to the window after floating.";
        };
        height = mkOption {
          type = types.nullOr types.int;
          default = null;
          description = "Fixed height to apply to the window after floating.";
        };
      };
    };

    rules = config.surfaces.niri.dynamic-float-rules;
  in {
    options.surfaces.niri.dynamic-float-rules = mkOption {
      type = types.listOf ruleType;
      default = [];
      description = ''
        Dynamic float rules. Each rule is checked against newly seen windows;
        on first match the daemon floats the window, optionally resizes it,
        and centers it. Useful for windows whose title or app_id only
        settles after launch.
      '';
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
}
