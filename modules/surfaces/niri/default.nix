{
  self,
  inputs,
  ...
}: {
  flake-file.inputs.niri-nix.url = "git+https://codeberg.org/BANanaD3V/niri-nix";

  flake = {
    modules = {
      nixos.niri = {pkgs, ...}: {
        imports = [
          self.modules.nixos.bongocat
          self.modules.nixos.fonts
          self.modules.nixos.geoclue
          self.modules.nixos.greeter
          self.modules.nixos.gtk
          self.modules.nixos.portals
        ];

        nix.settings = {
          substituters = ["https://niri-nix.cachix.org"];
          trusted-public-keys = ["niri-nix.cachix.org-1:SvFtqpDcf7Sm1SMJdby1/+Y+6f3Yt3/3PMcSTKPJNJ0="];
        };

        services.displayManager.sessionPackages = [pkgs.niri-unstable];

        xdg.portal = {
          config.niri.default = ["gnome" "gtk"];
          extraPortals = [pkgs.xdg-desktop-portal-gnome pkgs.xdg-desktop-portal-gtk];
        };
      };

      homeManager = {
        niri = {pkgs, ...}: {
          imports = with self.modules.homeManager; [
            dankmaterialshell-panel
            dankmaterialshell-panel-niri
            fonts
            niri-nix
            niri-options
          ];

          wayland.windowManager.niri = {
            enable = true;
            package = pkgs.niri-unstable;
          };
        };

        niri-nix = {
          key = "niri-nix-home-module";
          imports = [inputs.niri-nix.homeModules.default];
        };
      };
    };

    overlays.niri-nix = inputs.niri-nix.overlays.niri-nix;
  };

  flake.overlays.niri = _: prev: {
    libdisplay-info_0_3 = prev.libdisplay-info;
  };
}
