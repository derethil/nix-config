{
  lib,
  config,
  ...
}:
with lib;
with internal; let
  cfg = config.desktop.hyprland;
  yGap = cfg.gap;
  xGap = cfg.smallerLoneWindows.gap or yGap;
in {
  options.desktop.hyprland.smallerLoneWindows = with types; {
    enable = mkBoolOpt false "Whether to make windows smaller if they are the only window in a workspace.";
    gap = mkOpt int 500 "Outer gap size for smaller lone windows.";
  };

  config = mkIf (cfg.enable && cfg.smallerLoneWindows.enable) {
    wayland.windowManager.hyprland = {
      settings.workspace = [
        "w[t1] s[false], gapsout:${yGap} ${xGap} ${yGap} ${xGap}"
      ];
    };
  };
}
