{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.cli.trash-cli;
in {
  options.glace.cli.trash-cli = {
    enable = mkBoolOpt false "Whether to enable trash-cli.";
  };

  config = mkIf cfg.enable {
    home.packages = builtins.attrValues {
      inherit (pkgs) trash-cli;
    };

    glace.cli.aliases = {
      del = "trash-put";
      trash = "trash-put";
    };
  };
}

