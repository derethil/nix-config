{lib, ...}: let
  inherit (lib.internal) enabled enabled';
in {
  imports = [
    ./hardware.nix
  ];

  tools = {
    nh = enabled;
    neovim = enabled;
  };
  hardware = {
    nvidia-drivers = enabled;
    networking = enabled' {
      avahi = enabled;
    };
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

  services.openssh.enable = true;

  system.stateVersion = "25.11";
}
