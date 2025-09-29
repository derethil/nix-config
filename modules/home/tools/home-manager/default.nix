{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.tools.home-manager;
in {
  options.glace.tools.home-manager = {
    enable = mkBoolOpt false "Whether to enable the Home Manager CLI tool.";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      home-manager
    ];
  };
}
