{
  lib,
  pkgs,
  ...
}: let
  inherit (lib.glace) enabled enabled';
in {
  imports = [
    ./hardware.nix
  ];

  glace = {
    apps = {
      steam = enabled;
      sober = enabled;
    };
    tools = {
      nh = enabled;
      neovim = enabled;
    };
    hardware = {
      nvidia = enabled' {
        channel = "custom";
        package = pkgs.glace.nvidia-580-82-09;
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
      szuru = enabled' {
        allowedIPs = ["100.110.152.90"];
      };
    };
    system = {
      impermanence = enabled;
      time = enabled;
      fonts = enabled;
      boot = enabled' {
        plymouth = enabled;
      };
    };
    nix = {
      config = enabled;
    };
    desktop = {
      hyprland = enabled;
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
