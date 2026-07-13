{
  inputs,
  lib,
  ...
}: {
  imports = [
    inputs.flake-file.flakeModules.dendritic
  ];

  flake-file = {
    description = "Personal NixOS, Nix Darwin, and Home Manager configurations";

    inputs = {
      disko = {
        url = "github:nix-community/disko";
        inputs.nixpkgs.follows = "nixpkgs";
      };
    };

    outputs = lib.mkForce ''
      inputs@{flake-parts, import-tree, ...}:
      flake-parts.lib.mkFlake {inherit inputs;} (
        import-tree [
          ./modules
          ./flake
          ./hosts
          ./overlays
          ./templates
        ]
      )
    '';
  };
}
