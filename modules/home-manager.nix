{
  self,
  lib,
  ...
}: {
  # flake-parts ships option declarations for darwinConfigurations / nixosConfigurations
  # but not homeConfigurations (it's a home-manager convention, not a core flake output).
  # Declare it so multiple hosts can each contribute one entry.
  options.flake.homeConfigurations = lib.mkOption {
    default = {};
    type = lib.types.lazyAttrsOf lib.types.unspecified;
  };

  config = {
    flake-file.inputs.home-manager = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/home-manager/release-26.05";
    };

    flake.modules = {
      generic.home-manager-options.home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
      };

      nixos.home-manager = {
        imports = [self.modules.generic.home-manager-options];
        home-manager.sharedModules = [self.modules.homeManager.home-manager];
      };

      darwin.home-manager = {
        imports = [self.modules.generic.home-manager-options];

        home-manager = {
          sharedModules = [self.modules.homeManager.home-manager];
          useUserPackages = lib.mkForce false;
        };
      };

      homeManager.home-manager = {pkgs, ...}: {
        home.packages = [pkgs.unstable.home-manager];
      };
    };
  };
}
