{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
with glace; let
  cfg = config.glace.tools.hyprshot;
in {
  options.glace.tools.hyprshot = with types; {
    enable = mkBoolOpt false "Whether to enable hyprshot.";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      hyprshot
    ];
  };
}