{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
  inherit (lib) types;
  inherit (lib.internal) mkOpt;
in {
  options = {
    secrets = mkOpt types.attrs {} "Secrets to manage with SOPS.";
  };

  config = {
    home.packages = with pkgs; [sops age];
    sops = {
      age = {
        keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
        generateKey = true;
      };
      defaultSopsFile = "${inputs.secrets}/secrets.yaml";
      validateSopsFiles = false;
      secrets = config.secrets;
    };
    home.activation.sopsDirectories = config.lib.dag.entryAfter ["writeBoundary"] ''
      $DRY_RUN_CMD mkdir -p "${config.home.homeDirectory}/.config/sops/age"
    '';
  };
}
