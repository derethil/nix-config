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
    fonts = enabled;
    impermanence = enabled;
    time = enabled;
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

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  services.openssh.enable = true;

  system.stateVersion = "25.11";
}
