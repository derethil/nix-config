{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.apps.gaming.prismlauncher;
in {
  options.glace.apps.gaming.prismlauncher = {
    enable = mkBoolOpt false "Whether to enable Prism Launcher.";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      prismlauncher
    ];
  };
}
