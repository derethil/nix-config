{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkDefault types;
  inherit (lib.glace) mkBoolOpt mkNullableOpt;
  cfg = config.glace.system.time;
in {
  options.glace.system.time = {
    enable = mkBoolOpt false "Whether to enable time management.";
    automatic = mkBoolOpt true "Whether to enable automatic timezone detection based on location.";
    timeZone = mkNullableOpt types.str null "Manually set timezone (overrides automatic detection).";
  };

  config = mkIf cfg.enable {
    services.automatic-timezoned.enable = mkIf (cfg.automatic) true;
    time.timeZone = mkIf (!cfg.automatic) (mkDefault cfg.timeZone);
  };
}

