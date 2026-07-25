{
  self,
  lib,
  inputs,
  ...
}: {
  flake-file.inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

  perSystem = {system, ...}: {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;

      config = {
        allowDeprecatedx86_64Darwin = true; # silences 26.05 x86_64-darwin warnings
        allowUnfree = true;
      };

      overlays = lib.attrValues self.overlays;
    };
  };
}
