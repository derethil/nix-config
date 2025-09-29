{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.apps.bitwarden;
in {
  options.glace.apps.bitwarden = {
    enable = mkBoolOpt false "Whether to enable the Bitwarden Desktop client.";
  };

  config = mkIf cfg.enable {
    home.packages = [pkgs.bitwarden-desktop];
  };
}
