{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.internal) mkBoolOpt;
  cfg = config.apps.steam;
in {
  options.apps.steam = {
    enable = mkBoolOpt false "Enable Steam with Proton support";
  };

  config = mkIf cfg.enable {
    hardware.steam-hardware.enable = true;
    programs.steam = {
      enable = true;
      extest.enable = true;
      remotePlay.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
      extraCompatPackages = with pkgs; [
        proton-ge-bin
      ];
    };
    environment.sessionVariables = {
      STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
    };
  };
}
