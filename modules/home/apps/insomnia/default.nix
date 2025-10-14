{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.apps.insomnia;
in {
  options.glace.apps.insomnia = {
    enable = mkBoolOpt false "Whether to enable Insomnia.";
  };

  config = mkIf cfg.enable {
    home.packages = [pkgs.insomnia];
  };
}
