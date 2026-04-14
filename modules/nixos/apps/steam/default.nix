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
    extraEnv = mkOpt (types.attrsOf types.str) {} "Environment variables to set for Steam and its games.";
    cachyosOptimizations = mkBoolOpt true "Whether to enable CachyOS optimizations for Steam and steam games.";
  };

  config = mkIf cfg.enable {
    programs.steam = {
      enable = true;

      package = pkgs.steam.override {
        extraEnv =
          {
            GAMEMODERUN = "1";
            PROTON_LOCAL_SHADER_CACHE = "1";
            MESA_SHADER_CACHE_MAX_SIZE = "16G";
            DXVK_ASYNC = "1";
            PROTON_VKD3D_HEAP = "1";

            # TODO: ideally these would be set from the mangohud config but can't when separated between home manager and nixos
            MANGOHUD = "1";
            MANGOHUD_CONFIG = "read_cfg,no_display";
          }
          // cfg.extraEnv;
      };

      extest = {
        enable = false;
      };

      remotePlay = {
        openFirewall = true;
      };

      localNetworkGameTransfers = {
        openFirewall = true;
      };

      gamescopeSession = {
        enable = false;
      };

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
      capSysNice = false;
    };

    programs.gamemode = {
      enable = true;
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

    hardware = {
      steam-hardware.enable = true; # Steam Controller, Steam Deck, etc.
      xpadneo.enable = true; # Xbox controllers
    };
  };
}
