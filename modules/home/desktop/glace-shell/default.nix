{
  config,
  lib,
  ...
}:
with lib;
with glace; let
  cfg = config.glace.desktop.glace-shell;
in {
  options.glace.desktop.glace-shell = {
    enable = mkBoolOpt false "Whether to enable glace-shell.";
  };

  config = mkIf cfg.enable {
    services.glace-shell.enable = true;
  };
}
