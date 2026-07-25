{lib, ...}: {
  flake.modules.darwin.night-shift = {config, ...}: let
    inherit (lib) mkIf mkOption types;
    cfg = config.internal.night-shift;
  in {
    options.internal.night-shift = {
      automatic = mkOption {
        default = true;
        description = "Enable automatic Night Shift based on time of day.";
        type = types.bool;
      };

      colorTemperature = mkOption {
        default = 3233.05;
        description = "Color temperature target (2000-6500K range).";
        type = types.float;
      };

      schedule = {
        dayStartHour = mkOption {
          default = 7;
          description = "Hour when Night Shift turns off (0-23).";
          type = types.int;
        };

        dayStartMinute = mkOption {
          default = 0;
          description = "Minute when Night Shift turns off (0-59).";
          type = types.int;
        };

        nightStartHour = mkOption {
          default = 22;
          description = "Hour when Night Shift turns on (0-23).";
          type = types.int;
        };

        nightStartMinute = mkOption {
          default = 0;
          description = "Minute when Night Shift turns on (0-59).";
          type = types.int;
        };
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
