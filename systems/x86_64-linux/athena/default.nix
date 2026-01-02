{
  lib,
  pkgs,
  ...
}: let
  inherit (lib.glace) enabled disabled enabled';
in {
  imports = [
    ./hardware.nix
  ];

  glace = {
    apps = {
      steam = enabled;
      sober = enabled;
      lutris = disabled;
      faugus-launcher = enabled;
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
      nvidia = enabled' {
        channel = "beta";
        useUnstable = true;
      };
      audio = enabled;
      bluetooth = enabled;
      networking = enabled' {
        avahi = enabled;
      };
    };
    services = {
      openssh-server = enabled;
      flatpak = enabled;
      locate = enabled;
      szuru = enabled;
      usbmuxd = enabled;
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
        };
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
