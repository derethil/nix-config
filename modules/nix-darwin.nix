{
  flake-file.inputs.nix-darwin = {
    url = "github:LnL7/nix-darwin/nix-darwin-26.05";
    inputs.nixpkgs.follows = "nixpkgs";
  };
}
