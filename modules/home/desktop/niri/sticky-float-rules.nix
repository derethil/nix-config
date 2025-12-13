{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) types mkIf getExe;
  inherit (lib.glace) mkSubmoduleListOpt mkOpt;
  cfg = config.glace.desktop.niri;
  rules = config.glace.desktop.niri.sticky-float-rules;

  matchType = with types; {
    title = mkOpt (nullOr str) null "Window title regex pattern to match";
    app_id = mkOpt (nullOr str) null "App ID regex pattern to match";
  };

  ruleType = {
    match = mkSubmoduleListOpt "List of match conditions (OR logic)" matchType;
    exclude = mkSubmoduleListOpt "List of exclude conditions (OR logic)" matchType;
  };
in {
  options.glace.desktop.niri.sticky-float-rules = mkSubmoduleListOpt "List of sticky float window rules." ruleType;

  config = mkIf (cfg.enable && builtins.length rules > 0) {
    programs.niri.settings.spawn-at-startup = [
      {
        argv = [
          (getExe pkgs.glace.niri-sticky-float-rules)
          "-rules"
          "${config.xdg.configHome}/niri/sticky-float-rules.json"
        ];
      }
    ];

    xdg.configFile."niri/sticky-float-rules.json".source = pkgs.writeText "sticky-float-rules.json" (builtins.toJSON rules);
  };
}
