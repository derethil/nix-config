# Sticky window rules daemon — keeps matching windows pinned across workspaces.
# Source lives alongside this file (go.mod, main.go). The HM module exposes
# the option schema and, when rules are defined, writes them to JSON and
# launches the daemon via niri's spawn-at-startup.
{lib, ...}: {
  flake.modules.homeManager.niri-sticky-float-rules = {
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

        match = mkOption {
          default = [];
          description = "List of match conditions (OR logic).";
          type = types.listOf matchType;
        };
      };
    };

    rules = config.surfaces.niri.sticky-float-rules;
  in {
    options.surfaces.niri.sticky-float-rules = mkOption {
      default = [];

      description = ''
        Sticky float rules. Matching windows stay pinned across workspaces
        via a small daemon. See https://github.com/YaLTeR/niri/issues/932
        for why this can't be a native niri window-rule yet.
      '';

      type = types.listOf ruleType;
    };

    config = lib.mkIf (rules != []) {
      wayland.windowManager.niri.settings.spawn-at-startup = [
        {
          _args = [
            "${getExe pkgs.internal.niri-sticky-float-rules} -rules ${config.xdg.configHome}/niri/sticky-float-rules.json"
          ];
        }
      ];

      xdg.configFile."niri/sticky-float-rules.json".source =
        pkgs.writeText "sticky-float-rules.json" (builtins.toJSON rules);
    };
  };

  perSystem = {
    pkgs,
    system,
    ...
  }:
    lib.optionalAttrs (lib.elem system lib.platforms.linux) {
      packages.niri-sticky-float-rules = pkgs.buildGoModule {
        pname = "niri-sticky-float-rules";
        src = ./.;
        vendorHash = null;
        version = "0.1.0";

        meta = {
          description = "Sticky window rules for niri compositor";
          mainProgram = "niri-sticky-float-rules";
        };
      };
    };
}
