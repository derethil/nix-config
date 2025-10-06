{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.apps.prismlauncher;
in {
  options.glace.apps.prismlauncher = {
    enable = mkBoolOpt false "Whether to enable Prism Launcher.";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      prismlauncher
    ];
  };
}
