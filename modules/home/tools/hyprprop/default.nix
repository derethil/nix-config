{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
with glace; let
  cfg = config.glace.tools.hyprprop;
in {
  options.glace.tools.hyprprop = with types; {
    enable = mkBoolOpt false "Whether to enable hyprprop.";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      hyprprop
    ];
  };
}