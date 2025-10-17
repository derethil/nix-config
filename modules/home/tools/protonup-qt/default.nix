{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.tools.protonup-qt;
in {
  options.glace.tools.protonup-qt = {
    enable = mkBoolOpt false "Whether to enable ProtonUp-Qt";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      protonup-qt
    ];
  };
}
