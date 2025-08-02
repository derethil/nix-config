{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.internal) mkBoolOpt;
  cfg = config.cli.trash-cli;
in {
  options.cli.trash-cli = {
    enable = mkBoolOpt false "Whether to enable trash-cli.";
  };

  config = mkIf cfg.enable {
    home.packages = builtins.attrValues {
      inherit (pkgs) trash-cli;
    };
    
    cli.aliases = {
      del = "trash-put";
      trash = "trash-put";
    };
  };
}