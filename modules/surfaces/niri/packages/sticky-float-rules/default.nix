# Sticky window rules daemon — keeps matching windows pinned across workspaces.
# Source lives alongside this file (go.mod, main.go). The HM module exposes
# the option schema and, when rules are defined, writes them to JSON and
# launches the daemon via niri's spawn-at-startup.
{lib, ...}: {
  perSystem = {
    system,
    pkgs,
    ...
  }:
    lib.optionalAttrs (lib.elem system lib.platforms.linux) {
      packages.niri-sticky-float-rules = pkgs.buildGoModule {
        pname = "niri-sticky-float-rules";
        version = "0.1.0";
        src = ./.;
        vendorHash = null;
        meta = {
          description = "Sticky window rules for niri compositor";
          mainProgram = "niri-sticky-float-rules";
        };
      };
    };

  flake.modules.homeManager.niri-sticky-float-rules = {
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
      };
    };

    rules = config.surfaces.niri.sticky-float-rules;
  in {
    options.surfaces.niri.sticky-float-rules = mkOption {
      type = types.listOf ruleType;
      default = [];
      description = ''
        Sticky float rules. Matching windows stay pinned across workspaces
        via a small daemon. See https://github.com/YaLTeR/niri/issues/932
        for why this can't be a native niri window-rule yet.
      '';
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
}
