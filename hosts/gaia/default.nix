{
  self,
  inputs,
  withSystem,
  ...
}: let
  inherit (self.lib) mergeModules;

  flakeRoot = "/home/derethil/.config/nix-config";

  displays = [
    {
      name = "Ultrawide";
      primary = true;
      port = "DP-2";
      resolution = {
        width = 3440;
        height = 1440;
      };
      framerate = 160;
      vrr = true;
      wallpaper = "fuji-bird.jpeg";
    }
  ];
in {
  # HOST CONFIGURATION

  flake.modules.nixos.gaia = {
    imports = with (mergeModules self.modules.generic self.modules.nixos); [
      # Host
      ./_hardware.nix
      ./_disko.nix
      ./_ath12k.nix

      # Framework
      user-derethil

      # Baseline
      foundation

      # Boot & persistence
      boot
      plymouth
      impermanence

      # Hardware
      audio
      bluetooth
      networking
      radeon
      self.modules.nixos.displays

      # System services
      coolercontrol-it87
      openrgb
      gnome-keyring
      docker

      # Desktop
      dankmaterialshell-greeter
      niri

      # Pursuits
      development
      gaming
      sunshine
      utilities

      # Hosted
      szuru
    ];

    internal = {
      inherit flakeRoot displays;

      boot = {
        kernel = {
          cachyos = {
            enable = true;
          };
        };

        impermanence = {
          luksDevice = "enc";
          blankSnapshot = "root-blank";
        };
      };

      services = {
        coolercontrol.it87.mmio = true;
        openrgb.startupProfile = "Minimal";
      };

      hardware = {
        networking.avahi.enable = true;
        radeon.ppfeaturemask = "0xfff7ffff";
      };
    };

    programs.wayland-bongocat = {
      inputDevices = ["/dev/input/event4"];
    };

    networking.hostName = "gaia";
    system.stateVersion = "25.11";
  };

  # HOME MANAGER CONFIGURATION

  flake.modules.homeManager.gaia-derethil = {
    imports = with self.modules.homeManager; [
      # Baseline
      foundation

      # Compositor
      niri

      # Terminals
      foot
      kitty

      # Surfaces
      easyeffects

      # Pursuits
      browsers
      comms-work
      development
      gaming
      media
      melonloader
      utilities

      # Services
      remote-pull
    ];

    internal = {
      inherit flakeRoot displays;

      services.remote-pull.targets = [
        {
          name = "monifactory";
          source = "ubuntu@129.146.48.13:/home/ubuntu/monifactory/backups/*";
          destination = "/home/derethil/backups/monifactory";
          schedule = "daily";
          delete = true;
        }
      ];

      gaming.mangohud = {
        coolantSensor = "/sys/class/hwmon/hwmon6/temp2_input";
        pciDevice = "0000:03:00.0";
      };
    };

    services.easyeffects = {
      preset = "EdEQ";
      extraPresets = {
        EdEQ = builtins.fromJSON (builtins.readFile ./easyeffects-presets/Edifier-Speakers.json);
        Pass = builtins.fromJSON (builtins.readFile ./easyeffects-presets/Passthrough.json);
      };
    };

    home.stateVersion = "25.05";
  };

  # HOST DEFINITION

  flake.nixosConfigurations.gaia = inputs.nixpkgs.lib.nixosSystem rec {
    system = "x86_64-linux";
    pkgs = withSystem system ({pkgs, ...}: pkgs);
    modules = [
      self.modules.nixos.gaia
      self.modules.nixos.home-manager
      inputs.disko.nixosModules.disko
      inputs.home-manager.nixosModules.home-manager
      {home-manager.users.derethil = self.modules.homeManager.gaia-derethil;}
    ];
  };

  # HOME MANAGER DEFINITION

  flake.homeConfigurations."derethil@gaia" = withSystem "x86_64-linux" ({pkgs, ...}:
    inputs.home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = {inherit self inputs;};
      modules = [
        self.modules.homeManager.home-manager
        self.modules.homeManager.gaia-derethil
        self.modules.homeManager.user-derethil
      ];
    });
}
