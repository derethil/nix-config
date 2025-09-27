{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.internal) mkBoolOpt;
  cfg = config.tools.nh;
in {
  options.tools.nh = {
    enable = mkBoolOpt false "Whether to enable nh (Nix helper) configuration.";
    clean = {
      enable = mkBoolOpt true "Whether to enable automatic nh clean service.";
    };
  };

  config = mkIf cfg.enable {
    environment = {
      systemPackages = [pkgs.nh];
    };
  };
}
