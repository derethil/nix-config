{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.internal) mkBoolOpt;
  cfg = config.apps.stremio;
in {
  options.apps.stremio = {
    enable = mkBoolOpt false "Whether to enable Stremio";
  };

  config.home.packages = with pkgs; [
    (mkIf cfg.enable stremio)
  ];
}

