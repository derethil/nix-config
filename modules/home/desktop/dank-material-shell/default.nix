{
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.internal) mkBoolOpt;
  cfg = config.desktop.dank-material-shell;
in {
  options.desktop.dank-material-shell = {
    enable = mkBoolOpt false "Whether to enable Dank Material Shell.";
    enableBrightnessControl = mkBoolOpt false "Whether to enable DMS brightness/backlight contro.";
  };

  imports = [
    ./hyprland.nix
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
    };
  };
}
