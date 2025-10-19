{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.cli.gtrash;
in {
  options.glace.cli.gtrash = {
    enable = mkBoolOpt false "Whether to enable gtrash.";
  };

  config = mkIf cfg.enable {
    home.packages = [pkgs.gtrash];
    glace.cli.aliases = {
      del = "gtrash put";
    };
  };
}
