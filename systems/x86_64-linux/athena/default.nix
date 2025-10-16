{lib, ...}: let
  inherit (lib.glace) enabled disabled enabled';
in {
  imports = [
    ./hardware.nix
  ];

  glace = {
    apps = {
      steam = enabled;
      sober = enabled;
    };
    cli = {
      fish = enabled;
    };
    tools = {
      nh = enabled;
      neovim = enabled;
    };
    hardware = {
      nvidia = enabled;
      audio = enabled;
      bluetooth = enabled;
      networking = enabled' {
        avahi = enabled;
      };
    };
    services = {
      openssh-server = enabled;
      flatpak = enabled;
      szuru = enabled' {
        allowedIPs = ["100.110.152.90"];
      };
    };
    system = {
      impermanence = enabled;
      time = enabled;
      fonts = enabled;
      ntsync = enabled;
      boot = enabled' {
        plymouth = enabled;
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
      uwsm = enabled;
      display-managers = {
        tuigreet = enabled;
      };
      addons = {
        dconf = enabled;
      };
    };
  };

  system.stateVersion = "25.11";
}
