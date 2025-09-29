{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.tools.hyprpicker;
in {
  options.glace.tools.hyprpicker = {
    enable = mkBoolOpt false "Whether to enable hyprpicker.";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      hyprpicker
    ];
  };
}
