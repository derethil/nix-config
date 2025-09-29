{
  config,
  lib,
  ...
}:
with lib;
with glace; let
  cfg = config.glace.cli.direnv;
in {
  options.glace.cli.direnv = {
    enable = mkBoolOpt false "Whether to enable direnv.";
  };

  config = mkIf cfg.enable {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
