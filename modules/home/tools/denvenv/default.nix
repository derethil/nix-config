{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.tools.devenv;
in {
  options.glace.tools.devenv = {
    enable = mkBoolOpt false "Whether to enable devenv.";
  };

  config = mkIf cfg.enable {
    home.packages = [pkgs.devenv];
  };
}
