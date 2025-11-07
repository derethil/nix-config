{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.apps.faugus-launcher;
in {
  options.glace.apps.faugus-launcher = {
    enable = mkBoolOpt false "Whether to enable Faugus Launcher";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      unstable.faugus-launcher
    ];
  };
}