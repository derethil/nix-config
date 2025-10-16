{
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.desktop.dank-material-shell.calendar;
in {
  options.glace.desktop.dank-material-shell.calendar = {
    enable = mkBoolOpt true "Whether to enable Dank Material Shell calendar event integration.";
  };

  config = mkIf cfg.enable {
    glace.services.calendars.enable = true;
  };
}
