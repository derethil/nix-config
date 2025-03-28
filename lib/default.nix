{
  pkgsFor,
  inputs,
}: let
  nixpkgs = inputs.nixpkgs.lib;
  home-manager = inputs.home-manager.lib;

  pkgs = import ./pkgs;

  lib = nixpkgs // home-manager // pkgs;
in
  lib // {inherit nixpkgs home-manager pkgs;}
