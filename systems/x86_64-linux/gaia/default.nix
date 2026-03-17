{
  lib,
  pkgs,
  ...
}: let
  inherit (lib.glace) enabled disabled enabled';
in {
  imports = [
    ./hardware.nix
    ./disko.nix
  ];

  glace = {
    apps = {
      steam = enabled;
      sober = enabled;
      lutris = disabled;
      faugus-launcher = enabled;
      bongocat = enabled;
    };
    cli = {
      fish = enabled;
      yazi.portal = enabled;
    };
    tools = {
      nh = enabled;
      wine = enabled;
      comma = enabled;
      development = {
        neovim = enabled;
      };
    };
    hardware = {
      audio = enabled;
      bluetooth = enabled;
      radeon = enabled' {
        mesa.useUnstable = true;
        ppfeaturemask = "0xfff7ffff";
      };
      networking = enabled' {
        avahi = enabled;
      };
    };
    services = {
      gnome-keyring = enabled;
      locate = enabled;
      openssh = enabled;
      openrgb = enabled' {
        startupProfile = "Minimal";
      };
      lact = enabled;
      coolercontrol = enabled' {
        it87 = enabled' {
          mmio = true;
        };
      };
      flatpak = enabled;
      szuru = enabled;
      sideloading = enabled;
    };
    system = {
      impermanence = enabled;
      time = enabled;
      fonts = enabled;
      ntsync = enabled;
      boot = enabled' {
        plymouth = enabled;
        kernelPackages = pkgs.linuxPackages_cachyos-lto;
        kernelParams = {
          fix-xhci-controllers = enabled;
          # seems to fix intermittent WiFi card detection issues
          disable-pcie-aspm = enabled;
        };
        ssh = enabled;
      };
    };
    nix = {
      config = enabled;
    };
    desktop = {
      hyprland = disabled;
      niri = enabled' {
        nvidia.limitVramHeap = true;
      };
      displayManagers = {
        tuigreet = disabled;
        dankGreeter = enabled;
      };
      addons = {
        dconf = enabled;
      };
    };
  };

  system.stateVersion = "25.11";
}
