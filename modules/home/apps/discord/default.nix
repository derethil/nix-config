{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
with internal; {
  options.apps.discord.enable = mkBoolOpt false "Whether to enable Discord";
  options.apps.vesktop.enable = mkBoolOpt false "Whether to enable Vesktop";

  config.home.packages = with pkgs; [
    (mkIf config.apps.discord.enable discord)
    (mkIf config.apps.vesktop.enable vesktop)
  ];
}
