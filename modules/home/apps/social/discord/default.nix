{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
in {
  options.glace.apps.social.discord.enable = mkBoolOpt false "Whether to enable Discord";
  options.glace.apps.social.vesktop.enable = mkBoolOpt false "Whether to enable Vesktop";

  config.home.packages = with pkgs; [
    (mkIf config.glace.apps.social.discord.enable discord)
    (mkIf config.glace.apps.social.vesktop.enable vesktop)
  ];
}
