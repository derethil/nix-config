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
    enableBrightnessControl = mkBoolOpt false "Whether to enable DMS brightness/backlight contro.";
    calendar = {
      enable = mkBoolOpt cfg.enable "Whether to enable Dank Material Shell calendar event integration.";
    };
  };

  imports = [
    "${inputs.home-manager-unstable.outPath}/modules/programs/quickshell.nix"
    ./hyprland.nix
    ./niri.nix
  ];

  config = mkIf cfg.enable {
    programs.dankMaterialShell = {
      enable = true;
      enableSystemd = true;
      enableSystemMonitoring = true;
      enableClipboard = true;
      enableVPN = false;
      enableColorPicker = true;
      enableDynamicTheming = true;
      enableAudioWavelength = true;
      enableCalendarEvents = true;
      enableSystemSound = true;

      inherit (cfg) enableBrightnessControl;

      quickshell.package = pkgs.inputs.quickshell.default;

      plugins = with inputs; {
        DankPomodoroTimer.src = "${dms-official-plugins}/DankPomodoroTimer";
        DankBatteryAlerts.src = "${dms-official-plugins}/DankBatteryAlerts";
        DankCalculator.src = "${dms-calculator}";
        DankPowerUsage.src = "${dms-power-usage}";
        DankEmojiLauncher.src = "${dms-emoji-launcher}";
      };
    };

    glace.services.calendars = mkIf cfg.calendar.enable {
      enable = true;
    };
  };
}
