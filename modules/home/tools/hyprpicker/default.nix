{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
with glace; let
  cfg = config.glace.tools.hyprpicker;
in {
  options.glace.tools.hyprpicker = with types; {
    enable = mkBoolOpt false "Whether to enable hyprpicker.";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      hyprpicker
    ];
  };
}
