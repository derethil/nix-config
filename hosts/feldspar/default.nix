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
      framerate = 160;
      name = "Ultrawide";
      port = "DP-2";
      primary = true;

      resolution = {
        height = 1440;
        width = 3440;
      };

      vrr = true;
      wallpaper = "fuji-bird.jpeg";
    }
  ];
in {
  flake = {
    # HOST CONFIGURATION
    modules = {
      nixos.feldspar = {
        imports = with (mergeModules self.modules.generic self.modules.nixos); [
          ./_disko.nix
          ./_hardware.nix
          audio
          bluetooth
          boot
          coolercontrol-it87
          dankmaterialshell-greeter
          development
          docker
          feldspar-ath12k-fixes
          foundation
          gaming
          gnome-keyring
          impermanence
          networking
          niri
          openrgb
          plymouth
          radeon
          self.modules.nixos.displays
          sunshine
          tandoor-recipes
          user-derethil
          utilities
          virtualization
        ];

        internal = {
          inherit displays flakeRoot;

          boot = {
            impermanence = {
              blankSnapshot = "root-blank";
              luksDevice = "enc";
            };

            kernel.cachyos.enable = true;
          };

          hardware = {
            networking.avahi.enable = true;
            radeon.ppfeaturemask = "0xfff7ffff";
          };

          services = {
            coolercontrol.it87.mmio = true;
            openrgb.startupProfile = "Minimal";
          };
        };

        networking.hostName = "feldspar";
        programs.wayland-bongocat.inputDevices = ["/dev/input/event4"];
        system.stateVersion = "25.11";
      };

      # HOME MANAGER CONFIGURATION

      homeManager.feldspar-derethil = {
        imports = with self.modules.homeManager; [
          browsers
          comms-work
          development
          easyeffects
          foot
          foundation
          gaming
          kitty
          media
          melonloader
          niri
          remote-pull
          utilities
        ];

        home.stateVersion = "25.05";

        internal = {
          inherit displays flakeRoot;

          gaming.mangohud = {
            coolantSensor = "/sys/class/hwmon/hwmon6/temp2_input";
            pciDevice = "0000:03:00.0";
          };

          services.remote-pull.targets = [
            {
              delete = true;
              destination = "/home/derethil/backups/monifactory";
              name = "monifactory";
              schedule = "daily";
              source = "ubuntu@129.146.48.13:/home/ubuntu/monifactory/backups/*";
            }
          ];
        };

        services.easyeffects = {
          extraPresets = {
            EdEQ = builtins.fromJSON (builtins.readFile ./easyeffects-presets/Edifier-Speakers.json);
            Pass = builtins.fromJSON (builtins.readFile ./easyeffects-presets/Passthrough.json);
          };

          preset = "EdEQ";
        };
      };
    };

    # HOST DEFINITION
    nixosConfigurations.feldspar = inputs.nixpkgs.lib.nixosSystem rec {
      modules = [
        inputs.disko.nixosModules.disko
        inputs.home-manager.nixosModules.home-manager
        self.modules.nixos.feldspar
        self.modules.nixos.home-manager
        {home-manager.users.derethil = self.modules.homeManager.feldspar-derethil;}
      ];

      pkgs = withSystem system ({pkgs, ...}: pkgs);
      system = "x86_64-linux";
    };

    # HOME MANAGER DEFINITION
    homeConfigurations."derethil@feldspar" = withSystem "x86_64-linux" ({pkgs, ...}:
      inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {inherit inputs self;};

        modules = [
          self.modules.homeManager.feldspar-derethil
          self.modules.homeManager.home-manager
          self.modules.homeManager.user-derethil
        ];
      });
  };
}
