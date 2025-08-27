{
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.internal) mkBoolOpt;
  cfg = config.apps.mediamate;
in {
  options.apps.mediamate = {
    enable = mkBoolOpt true "Whether to enable Mediamate, a Dynamic Island app for media controls.";
  };

  config = mkIf cfg.enable {
    tools.homebrew.casks = ["mediamate"];
  };
}
