{
  config,
  lib,
  ...
}:
with lib;
with internal; let
  cfg = config.cli.direnv;
in {
  options.cli.direnv = {
    enable = mkBoolOpt false "Whether to enable direnv.";
  };

  config = mkIf cfg.enable {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
