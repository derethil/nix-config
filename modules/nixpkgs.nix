{
  self,
  inputs,
  lib,
  ...
}: {
  flake-file.inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
  };

  perSystem = {system, ...}: {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
        allowDeprecatedx86_64Darwin = true; # silences 26.05 x86_64-darwin warnings
      };
      overlays = lib.attrValues self.overlays;
    };
  };
}
