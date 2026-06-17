{
  self,
  lib,
  ...
}: {
  # flake-parts ships option declarations for darwinConfigurations / nixosConfigurations
  # but not homeConfigurations (it's a home-manager convention, not a core flake output).
  # Declare it so multiple hosts can each contribute one entry.
  options.flake.homeConfigurations = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.unspecified;
    default = {};
  };

  config = {
    flake-file.inputs = {
      home-manager = {
        url = "github:nix-community/home-manager/release-26.05";
        inputs.nixpkgs.follows = "nixpkgs";
      };
    };

    flake.modules.generic.home-manager-options = {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
      };
    };

    flake.modules.homeManager.home-manager = {pkgs, ...}: {
      home.packages = [pkgs.unstable.home-manager];
    };

    flake.modules.nixos.home-manager = {
      imports = [self.modules.generic.home-manager-options];
      home-manager.sharedModules = [self.modules.homeManager.home-manager];
    };

    flake.modules.darwin.home-manager = {
      imports = [self.modules.generic.home-manager-options];
      home-manager.useUserPackages = lib.mkForce false;
      home-manager.sharedModules = [self.modules.homeManager.home-manager];
    };
  };
}
