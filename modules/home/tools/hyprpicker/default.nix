{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
with internal; let
  cfg = config.tools.hyprpicker;
in {
  options.tools.hyprpicker = with types; {
    enable = mkBoolOpt false "Whether to enable hyprpicker.";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      hyprpicker
    ];
  };
}
