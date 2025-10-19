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
    enableBrightnessControl = mkBoolOpt false "Whether to enable DMS brightness/backlight contro.";
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
      enableSystemd = true;
      enableSystemMonitoring = true;
      enableClipboard = true;
      enableVPN = false;
      enableNightMode = false;
      enableDynamicTheming = true;
      enableAudioWavelength = true;
      enableCalendarEvents = true;
      inherit (cfg) enableBrightnessControl;

      quickshell.package = pkgs.inputs.quickshell.default;
    };

    glace.services.calendars = mkIf cfg.calendar.enable {
      enable = true;
    };
  };
}
