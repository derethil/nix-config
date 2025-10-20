{inputs, ...}: final: _: {
  # Alias package inputs:
  # - inputs.<input>.packages.<system>
  # - inputs.<input>.legacyPackages.<system>
  # - inputs.<input>.defaultPackage.<system>
  # to pkgs.inputs.<input>
  inputs =
    builtins.mapAttrs (
      _: flake: let
        packages = (flake.packages or {}).${final.system} or {};
        legacyPackages = (flake.legacyPackages or {}).${final.system} or {};
        defaultPackage = (flake.defaultPackage or {}).${final.system} or null;
        merged = legacyPackages // packages;
      in
        # If using old defaultPackage schema, normalize to { default = ...; }
        if merged == {} && defaultPackage != null
        then {default = defaultPackage;}
        else merged
    )
    inputs;
}
