{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
with internal; let
  cfg = config.apps.insomnia;
in {
  options.apps.insomnia = {
    enable = mkBoolOpt false "Whether to enable Insomnia.";
  };

  config.home.packages = with pkgs; [
    (mkIf cfg.enable insomnia)
  ];
}
