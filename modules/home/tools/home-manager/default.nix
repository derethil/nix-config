{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
with internal; let
  cfg = config.tools.home-manager;
in {
  options.tools.home-manager = {
    enable = mkBoolOpt false "Whether to enable the Home Manager CLI tool.";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      home-manager
    ];
  };
}
