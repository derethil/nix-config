{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.tools.reset-launch-services;
in {
  options.glace.tools.reset-launch-services = {
    enable = mkBoolOpt false "Whether to enable the reset-launch-services tool for fixing macOS default application associations.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.glace.reset-launch-services
    ];
  };
}