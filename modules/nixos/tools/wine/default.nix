{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.tools.wine;
in {
  options.glace.tools.wine = {
    enable = mkBoolOpt false "Whether to enable Wine";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      wineWowPackages.stable
      winetricks
    ];
  };
}