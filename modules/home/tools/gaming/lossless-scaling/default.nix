{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;

  cfg = config.glace.tools.gaming.lossless-scaling;
in {
  options.glace.tools.gaming.lossless-scaling = {
    enable = mkBoolOpt false "Enable lossless scaling (frame generation)";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs.unstable; [
      lsfg-vk
      lsfg-vk-ui
    ];
  };
}
