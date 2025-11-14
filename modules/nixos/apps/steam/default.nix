{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.apps.steam;
in {
  options.glace.apps.steam = {
    enable = mkBoolOpt false "Enable Steam with Proton support";
  };

  config = mkIf cfg.enable {
    hardware.steam-hardware.enable = true;
    programs.steam = {
      enable = true;
      extest.enable = false;
      remotePlay.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
      gamescopeSession.enable = true;
      extraCompatPackages = with pkgs; [
        mangohud
      ];
      protontricks = {
        enable = true;
        package = pkgs.unstable.protontricks;
      };
      # Provided by nix-gaming module
      platformOptimizations.enable = true;
    };

    programs.gamemode.enable = true;
  };
}
