{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.internal) mkBoolOpt;
  cfg = config.tools.reset-launch-services;
in {
  options.tools.reset-launch-services = {
    enable = mkBoolOpt false "Whether to enable the reset-launch-services tool for fixing macOS default application associations.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.internal.reset-launch-services
    ];
  };
}