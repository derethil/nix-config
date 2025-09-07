{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.internal) mkBoolOpt;
  cfg = config.apps.bitwarden;
in {
  options.apps.bitwarden = {
    enable = mkBoolOpt false "Whether to enable the Bitwarden Desktop client.";
  };

  config = mkIf cfg.enable {
    home.packages = [pkgs.bitwarden-desktop];
  };
}
