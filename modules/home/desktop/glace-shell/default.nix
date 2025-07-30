{
  config,
  lib,
  ...
}:
with lib;
with internal; let
  cfg = config.desktop.glace-shell;
in {
  options.desktop.glace-shell = {
    enable = mkBoolOpt false "Whether to enable glace-shell.";
  };

  config = mkIf cfg.enable {
    services.glace-shell.enable = true;
  };
}
