{inputs, ...}: {
  flake-file.inputs.nur = {
    inputs.nixpkgs.follows = "nixpkgs";
    url = "github:nix-community/NUR";
  };

  flake.overlays.nur = inputs.nur.overlays.default;
}
