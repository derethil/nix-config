{inputs, ...}: final: _: {
  inputs =
    builtins.mapAttrs (
      _: flake: let
        legacyPackages = (flake.legacyPackages or {}).${final.system} or {};
        packages = (flake.packages or {}).${final.system} or {};
        defaultPackage = (flake.defaultPackage or {}).${final.system} or null;
      in
        # If it's a big package set like nixpkgs, return the full set
        if legacyPackages != {}
        then legacyPackages // packages
        # Otherwise, return the single default package directly
        else if defaultPackage != null
        then defaultPackage # Old schema
        else if packages ? default
        then packages.default # New schema
        else packages # Fallback to package set if no default
    )
    inputs;
}
