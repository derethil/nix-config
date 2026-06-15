{lib, ...}: {
  flake.modules.darwin.night-shift = {config, ...}: let
    inherit (lib) mkOption mkIf types;
    cfg = config.internal.night-shift;
  in {
    options.internal.night-shift = {
      automatic = mkOption {
        type = types.bool;
        default = true;
        description = "Enable automatic Night Shift based on time of day.";
      };
      schedule = {
        dayStartHour = mkOption {
          type = types.int;
          default = 7;
          description = "Hour when Night Shift turns off (0-23).";
        };
        dayStartMinute = mkOption {
          type = types.int;
          default = 0;
          description = "Minute when Night Shift turns off (0-59).";
        };
        nightStartHour = mkOption {
          type = types.int;
          default = 22;
          description = "Hour when Night Shift turns on (0-23).";
        };
        nightStartMinute = mkOption {
          type = types.int;
          default = 0;
          description = "Minute when Night Shift turns on (0-59).";
        };
      };
      colorTemperature = mkOption {
        type = types.float;
        default = 3233.05;
        description = "Color temperature target (2000-6500K range).";
      };
    };

    config.system.defaults.CustomUserPreferences."com.apple.CoreBrightness" = {
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
}
