{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.desktop.dank-material-shell;
in {
  options.glace.desktop.dank-material-shell = {
    enable = mkBoolOpt false "Whether to enable Dank Material Shell.";
    calendar = {
      enable = mkBoolOpt cfg.enable "Whether to enable Dank Material Shell calendar event integration.";
    };
  };

  imports = [
    ./hyprland.nix
    ./niri.nix
  ];

  config = mkIf cfg.enable {
    programs.dank-material-shell = {
      enable = true;
      systemd = {
        enable = true;
        restartIfChanged = true;
      };
      dgop = {
        # TODO:: dgop is only on unstable branch, this is unnecessary once it is on stable
        package = pkgs.inputs.dgop.default;
      };
      enableVPN = false;

      enableSystemMonitoring = true;
      enableDynamicTheming = true;
      enableAudioWavelength = true;
      enableCalendarEvents = true;
      enableClipboardPaste = true;

      quickshell.package = pkgs.inputs.quickshell.default;

      plugins = {
        alarmClock.enable = true;
        powerUsagePlugin.enable = true;
        dankPomodoroTimer.enable = true;
        dankBatteryAlerts.enable = true;
        webSearch.enable = true;
        easyEffects.enable = config.glace.services.easyeffects.enable;
      };
    };

    glace.services.calendars = mkIf cfg.calendar.enable {
      enable = true;
    };
  };
}
