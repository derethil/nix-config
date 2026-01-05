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
        package = pkgs.protontricks;
      };
      # Provided by nix-gaming module
      platformOptimizations.enable = true;
    };

    programs.gamescope = {
      enable = true;
      capSysNice = false; # See https://github.com/NixOS/nixpkgs/issues/351516
    };

    environment.systemPackages = [
      pkgs.dotnetCorePackages.sdk_8_0-bin
      pkgs.fna3d
    ];

    services.ananicy = {
      enable = true;
      package = pkgs.ananicy-cpp;
      rulesProvider = pkgs.ananicy-cpp;
      extraRules = [
        {
          "name" = "gamescope";
          "nice" = -20;
        }
      ];
    };

    programs.gamemode.enable = true;
  };
}
