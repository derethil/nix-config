{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.cli.trashy;
in {
  options.glace.cli.trashy = {
    enable = mkBoolOpt false "Whether to enable Trashy.";
  };

  config = mkIf cfg.enable {
    home.packages = [pkgs.inputs.trashy];
    glace.cli.aliases = {
      del = "trashy put";
    };
  };
}
