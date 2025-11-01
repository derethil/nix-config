{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) types mkIf getExe;
  inherit (lib.glace) mkSubmoduleListOpt mkOpt;
  cfg = config.glace.desktop.niri;
  rules = config.glace.desktop.niri.dynamic-float-rules;

  matchType = with types; {
    title = mkOpt (nullOr str) null "Window title regex pattern to match";
    app_id = mkOpt (nullOr str) null "App ID regex pattern to match";
  };

  ruleType = with types; {
    match = mkSubmoduleListOpt "List of match conditions (OR logic)" matchType;
    exclude = mkSubmoduleListOpt "List of exclude conditions (OR logic)" matchType;
    width = mkOpt (nullOr int) null "Fixed width for the floating window";
    height = mkOpt (nullOr int) null "Fixed height for the floating window";
  };
in {
  options.glace.desktop.niri.dynamic-float-rules = mkSubmoduleListOpt "List of dynamic float window rules." ruleType;

  config = mkIf (cfg.enable && builtins.length rules > 0) {
    programs.niri.settings.spawn-at-startup = [
      {argv = [(getExe pkgs.glace.niri-dynamic-float-rules)];}
    ];

    xdg.configFile."niri/dynamic-float-rules.json".source = pkgs.writeText "dynamic-float-rules.json" (builtins.toJSON {
      rules = rules;
    });
  };
}
