{inputs, ...}: {
  flake-file.inputs.nur = {
    url = "github:nix-community/NUR";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.overlays.nur = inputs.nur.overlays.default;
}
