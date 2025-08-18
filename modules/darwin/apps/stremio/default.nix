{
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.internal) mkBoolOpt;
  cfg = config.apps.stremio;
in {
  # Stremio fails to build on Darwin, so use homebrew to install it instead

  options.apps.stremio = {
    enable = mkBoolOpt false "Whether to enable the Stremio streaming service.";
  };

  config = mkIf cfg.enable {
    tools.homebrew.casks = [ "stremio" ];
  };
}
