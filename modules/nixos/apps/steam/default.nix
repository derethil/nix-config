{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf types;
  inherit (lib.glace) mkBoolOpt mkOpt;
  cfg = config.glace.apps.steam;
in {
  options.glace.apps.steam = {
    enable = mkBoolOpt false "Enable Steam with Proton support";
    cachyosOptimizations = mkBoolOpt true "Whether to enable CachyOS optimizations for Steam and steam games.";
  };

  config = mkIf cfg.enable {
    hardware.steam-hardware.enable = true;
    programs.steam = {
      enable = true;
      extest.enable = false;
      remotePlay.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
      gamescopeSession.enable = false;
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

    environment.systemPackages = [
      pkgs.dotnetCorePackages.sdk_8_0-bin
      pkgs.fna3d
    ];

    programs.gamescope = {
      enable = true;
      capSysNice = false;
    };

    # work around for issue with capSysNice not working in gamescope. even though it still
    # complains that it doesn't have cap nice ability to set it its own nice value.  ananicy
    # is setting it -20 (highest priority).
    # See: https://github.com/NixOS/nixpkgs/issues/351516
    services.ananicy = mkIf cfg.cachyosOptimizations {
      enable = true;
      package = pkgs.ananicy-cpp;
      rulesProvider = pkgs.ananicy-rules-cachyos;
    };

    programs.gamemode.enable = true;
  };
}
