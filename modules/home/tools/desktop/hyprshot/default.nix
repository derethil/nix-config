{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.tools.desktop.hyprshot;
in {
  options.glace.tools.desktop.hyprshot = {
    enable = mkBoolOpt false "Whether to enable hyprshot.";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      hyprshot
    ];
  };
}

