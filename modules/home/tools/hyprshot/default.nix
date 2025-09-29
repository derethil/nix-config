{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.tools.hyprshot;
in {
  options.glace.tools.hyprshot = {
    enable = mkBoolOpt false "Whether to enable hyprshot.";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      hyprshot
    ];
  };
}

