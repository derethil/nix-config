# Taken from: https://github.com/gytis-ivaskevicius/flake-utils-plus/blob/afcb15b845e74ac5e998358709b2b5fe42a948d1/lib/options.nix
{
  lib,
  config,
  inputs,
  ...
}: let
  inherit (lib) mkIf filterAttrs mapAttrs';
  inherit (lib.internal) mkBoolOpt;

  flakes = filterAttrs (name: value: value ? outputs) inputs;

  nixRegistry =
    builtins.mapAttrs
    (name: v: {flake = v;})
    flakes;

  cfg = config.nix.inputs;
in {
  options.nix.inputs = {
    generateNixPathFromInputs = mkBoolOpt false "Generate NIX_PATH from available inputs.";
    generateRegistryFromInputs = mkBoolOpt false "Generate Nix registry from available inputs.";
    linkInputs = mkBoolOpt false "Symlink inputs to /etc/nix/inputs.";
  };

  config = mkIf config.nix.config.enable {
    assertions = [
      {
        assertion = !cfg.generateNixPathFromInputs || cfg.linkInputs;
        message = "When using 'nix.generateNixPathFromInputs' please make sure to set 'nix.linkInputs = true'";
      }
    ];

    nix.registry =
      if cfg.generateRegistryFromInputs
      then nixRegistry
      else {self.flake = flakes.self;};

    environment.etc = mkIf (cfg.linkInputs || cfg.generateNixPathFromInputs) (mapAttrs'
      (name: value: {
        name = "nix/inputs/${name}";
        value = {source = value.outPath;};
      })
      inputs);

    nix.nixPath = mkIf cfg.generateNixPathFromInputs ["/etc/nix/inputs"];
  };
}
