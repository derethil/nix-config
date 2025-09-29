{
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.apps.steam;
in {
  options.glace.apps.steam = {
    enable = mkBoolOpt false "Whether to enable Steam gaming platform.";
  };

  config = mkIf cfg.enable {
    tools.homebrew.casks = [ "steam" ];
  };
}