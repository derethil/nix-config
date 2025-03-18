
{
  description = "My Home Manager Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.11";
    systems.url = "github:nix-systems/default-linux";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, systems, ... }@inputs: let
    inherit (self) outputs;
    lib = nixpkgs.lib // home-manager.lib;
    forEachSystem = f: lib.genAttrs (import systems) (system: f pkgsFor.${system});
    pkgsFor = lib.genAttrs (import systems) (
      system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        }
    );
  in {
    inherit lib;

    defaultPackage.x86_64-linux = home-manager.packages.x86_64-linux.home-manager;

    homeConfigurations = {
      "derethil@artemis" = lib.homeManagerConfiguration {
        pkgs = pkgsFor.x86_64-linux;
        modules = [ ./home.nix ];
        extraSpecialArgs = {
          inherit inputs outputs;
        };
      };
    };
  };
}
