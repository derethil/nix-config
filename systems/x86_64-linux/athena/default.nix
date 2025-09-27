{
  pkgs,
  lib,
  ...
}: let
  inherit (lib.internal) enabled;
in {
  imports = [
    ./hardware.nix
  ];

  tools = {
    nh = enabled;
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "athena";

  networking.networkmanager.enable = true;

  time.timeZone = "US/Denver";

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  users.users.derethil = {
    isNormalUser = true;
    extraGroups = ["wheel" "networkmanager"];
  };

  services.openssh.enable = true;

  system.stateVersion = "25.11";
}
