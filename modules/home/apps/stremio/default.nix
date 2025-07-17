{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
with internal; let
  cfg = config.apps.stremio;
in {
  options.apps.stremio = {
    enable = mkBoolOpt false "Whether to enable Stremio";
  };

  config.home.packages = with pkgs; [
    (mkIf cfg.enable stremio)
  ];
}