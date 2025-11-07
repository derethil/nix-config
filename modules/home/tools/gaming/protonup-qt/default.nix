{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.tools.gaming.protonup-qt;
in {
  options.glace.tools.gaming.protonup-qt = {
    enable = mkBoolOpt false "Whether to enable ProtonUp-Qt";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      protonup-qt
    ];
  };
}
