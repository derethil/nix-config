{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.tools.hyprprop;
in {
  options.glace.tools.hyprprop = {
    enable = mkBoolOpt false "Whether to enable hyprprop.";
  };

  config = mkIf cfg.enable {
    home.packages = [pkgs.hyprprop];
  };
}

