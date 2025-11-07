{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.apps.lutris;
in {
  options.glace.apps.lutris = {
    enable = mkBoolOpt false "Whether to enable lutris gaming platform";
  };

  config = mkIf cfg.enable {
    hardware.opengl = {
      enable = true;
      driSupport32Bit = true;
    };
    
    programs.gamemode.enable = true;
    
    environment.systemPackages = with pkgs; [
      lutris
      wine
      winetricks
    ];
  };
}