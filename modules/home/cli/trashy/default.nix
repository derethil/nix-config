{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with glace; let
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
