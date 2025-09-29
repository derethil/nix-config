{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
with glace; {
  options.glace.apps.discord.enable = mkBoolOpt false "Whether to enable Discord";
  options.glace.apps.vesktop.enable = mkBoolOpt false "Whether to enable Vesktop";

  config.home.packages = with pkgs; [
    (mkIf config.glace.apps.discord.enable discord)
    (mkIf config.glace.apps.vesktop.enable vesktop)
  ];
}
