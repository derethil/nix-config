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

  config = mkIf cfg.enable {
    home.packages = [pkgs.inputs.nixpkgs-for-stremio.stremio];
  };
}
