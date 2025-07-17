{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
with internal; let
  cfg = config.tools.hyprshot;
in {
  options.tools.hyprshot = with types; {
    enable = mkBoolOpt false "Whether to enable hyprshot.";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      hyprshot
    ];
  };
}