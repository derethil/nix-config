{
  flake-file.inputs.nix-darwin = {
    inputs.nixpkgs.follows = "nixpkgs";
    url = "github:LnL7/nix-darwin/nix-darwin-26.05";
  };
}
