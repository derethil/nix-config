{
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf types;
  inherit (lib.internal) mkBoolOpt mkOpt;
  cfg = config.desktop.night-shift;
in {
  options.desktop.night-shift = {
    enable = mkBoolOpt false "Whether to enable Night Shift.";
    automatic = mkBoolOpt true "Whether to enable automatic Night Shift based on time of day.";
    schedule = {
      dayStartHour = mkOpt types.int 7 "Hour when Night Shift turns off (0-23).";
      dayStartMinute = mkOpt types.int 0 "Minute when Night Shift turns off (0-59).";
      nightStartHour = mkOpt types.int 22 "Hour when Night Shift turns on (0-23).";
      nightStartMinute = mkOpt types.int 0 "Minute when Night Shift turns on (0-59).";
    };
    colorTemperature = mkOpt types.float 3433.05 "Color temperature target (2000-6500K range).";
  };

  config = mkIf cfg.enable {
    system.defaults.CustomUserPreferences = {
      "com.apple.CoreBrightness" = {
        CBBlueLightReductionCCTTargetRaw = cfg.colorTemperature;
        CBBlueReductionStatus = {
          AutoBlueReductionEnabled =
            if cfg.automatic
            then 1
            else 0;
          BlueLightReductionSchedule = mkIf (!cfg.automatic) {
            DayStartHour = cfg.schedule.dayStartHour;
            DayStartMinute = cfg.schedule.dayStartMinute;
            NightStartHour = cfg.schedule.nightStartHour;
            NightStartMinute = cfg.schedule.nightStartMinute;
          };
          BlueReductionEnabled = 1;
          BlueReductionMode = 1;
          BlueReductionSunScheduleAllowed =
            if cfg.automatic
            then 1
            else 0;
          Version = 1;
        };
      };
    };
  };
}
