{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
with internal; let
  cfg = config.tools.hyprprop;
in {
  options.tools.hyprprop = with types; {
    enable = mkBoolOpt false "Whether to enable hyprprop.";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      hyprprop
    ];
  };
}