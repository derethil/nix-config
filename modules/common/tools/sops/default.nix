{
  config,
  lib,
  inputs,
  ...
}: let
  inherit (lib) types;
  inherit (lib.glace) mkOpt;
in {
  options = {
    secrets = mkOpt types.attrs {} "Secrets to manage with SOPS.";
  };

  config = {
    sops = {
      age.generateKey = false;
      defaultSopsFile = "${inputs.secrets}/secrets.yaml";
      validateSopsFiles = true;
      secrets = config.secrets;
    };
  };
}
