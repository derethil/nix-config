{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.apps.stremio;
in {
  options.glace.apps.stremio = {
    enable = mkBoolOpt false "Whether to enable Stremio";
  };

  config.home.packages = with pkgs; [
    (mkIf cfg.enable stremio)
  ];
}

