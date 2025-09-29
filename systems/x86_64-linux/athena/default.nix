{lib, ...}: let
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
      nvidia = enabled;
      networking = enabled' {
        avahi = enabled;
      };
    };
    services = {
      openssh-server = enabled;
      flatpak = enabled;
    };
    system = {
      impermanence = enabled;
      audio = enabled;
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
