{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.internal) mkBoolOpt;
  cfg = config.tools.devenv;
in {
  options.tools.devenv = {
    enable = mkBoolOpt false "Whether to enable devenv.";
  };

  config = mkIf cfg.enable {
    home.packages = [pkgs.devenv];
  };
}
