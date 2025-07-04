{inputs, ...}: final: _: {
  inputs =
    builtins.mapAttrs (
      _: flake: let
        legacyPackages = (flake.legacyPackages or {}).${final.system} or {};
        packages = (flake.packages or {}).${final.system} or {};
        defaultPackage = (flake.defaultPackage or {}).${final.system} or {};
      in
        if legacyPackages != {}
        then legacyPackages // packages # Merge packages into legacyPackages
        else if defaultPackage != {}
        then defaultPackage
        else packages
    )
    inputs;
}
