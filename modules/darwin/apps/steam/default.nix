{
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.internal) mkBoolOpt;
  cfg = config.apps.steam;
in {
  options.apps.steam = {
    enable = mkBoolOpt false "Whether to enable Steam gaming platform.";
  };

  config = mkIf cfg.enable {
    tools.homebrew.casks = [ "steam" ];
  };
}