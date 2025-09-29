{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
with glace; let
  cfg = config.glace.apps.insomnia;
in {
  options.glace.apps.insomnia = {
    enable = mkBoolOpt false "Whether to enable Insomnia.";
  };

  config.home.packages = with pkgs; [
    (mkIf cfg.enable insomnia)
  ];
}
