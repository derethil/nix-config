{
  self,
  inputs,
  ...
}: {
  flake-file.inputs.niri-nix = {
    url = "git+https://codeberg.org/BANanaD3V/niri-nix";
  };

  flake = {
    overlays.niri-nix = inputs.niri-nix.overlays.niri-nix;

    modules = {
      homeManager.niri-nix = {
        key = "niri-nix-home-module";
        imports = [inputs.niri-nix.homeModules.default];
      };

      nixos.niri = {pkgs, ...}: {
        imports = [
          self.modules.nixos.portals
          self.modules.nixos.greeter
          self.modules.nixos.bongocat
          self.modules.nixos.gtk
          self.modules.nixos.fonts
          self.modules.nixos.geoclue
        ];

        xdg.portal = {
          extraPortals = [pkgs.xdg-desktop-portal-gnome pkgs.xdg-desktop-portal-gtk];
          config.niri.default = ["gnome" "gtk"];
        };

        services.displayManager = {
          sessionPackages = [pkgs.niri-unstable];
        };

        nix.settings = {
          substituters = ["https://niri-nix.cachix.org"];
          trusted-public-keys = ["niri-nix.cachix.org-1:SvFtqpDcf7Sm1SMJdby1/+Y+6f3Yt3/3PMcSTKPJNJ0="];
        };
      };

      homeManager.niri = {pkgs, ...}: {
        imports = with self.modules.homeManager; [
          niri-nix
          niri-options
          dankmaterialshell-panel
          dankmaterialshell-panel-niri
          fonts
        ];

        wayland.windowManager.niri = {
          enable = true;
          package = pkgs.niri-unstable;
        };
      };
    };
  };
}
