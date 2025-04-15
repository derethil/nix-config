{
  inputs,
  outputs,
}: {
  # For every flake input, aliases 'pkgs.inputs.${flake}' to
  # 'inputs.${flake}.packages.${pkgs.system}' or
  # 'inputs.${flake}.legacyPackages.${pkgs.system}' or
  # 'inputs.${flake}.defaultPackage.${pkgs.system}'
  flake-inputs = final: _: {
    inputs =
      builtins.mapAttrs (
        _: flake: let
          legacyPackages = (flake.legacyPackages or {}).${final.system} or {};
          packages = (flake.packages or {}).${final.system} or {};
          defaultPackage = (flake.defaultPackage or {}).${final.system} or {};
        in
          if legacyPackages != {}
          then legacyPackages
          else if defaultPackage != {}
          then defaultPackage
          else packages
      )
      inputs;
  };
}
