{
  lib,
  config,
  inputs,
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
    programs.dankMaterialShell = {
      enable = true;
      systemd = {
        enable = true;
        restartIfChanged = true;
      };
      enableSystemMonitoring = true;
      enableVPN = false;
      enableDynamicTheming = true;
      enableAudioWavelength = true;
      enableCalendarEvents = true;

      quickshell.package = pkgs.inputs.quickshell.default;

      plugins = with inputs; {
        DankPomodoroTimer.src = "${dms-official-plugins}/DankPomodoroTimer";
        DankBatteryAlerts.src = "${dms-official-plugins}/DankBatteryAlerts";
        AlarmClock.src = "${dms-lucyfire-plugins}/alarmClock";
      };
    };

    glace.services.calendars = mkIf cfg.calendar.enable {
      enable = true;
    };
  };
}
