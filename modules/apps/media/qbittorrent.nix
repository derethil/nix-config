{
  flake.modules.nixos.qbittorrent = {pkgs, ...}: let
    port = 48530;
  in {
    home-manager.sharedModules = [
      {home.packages = [pkgs.qbittorrent];}
    ];

    networking.firewall = {
      allowedTCPPorts = [port];
      allowedUDPPorts = [port];
    };
  };
}
