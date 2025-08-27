{
  config,
  lib,
  inputs,
  ...
}: let
  inherit (lib) types;
  inherit (lib.internal) mkOpt;
in {
  options = {
    secrets = mkOpt types.attrs {} "Secrets to manage with SOPS.";
    keyFile = mkOpt types.str "" "Path to the SOPS age key file.";
  };

  config = {
    sops = {
      age.generateKey = true;
      defaultSopsFile = "${inputs.secrets}/secrets.yaml";
      validateSopsFiles = false;
      secrets = config.secrets;
    };
  };
}
