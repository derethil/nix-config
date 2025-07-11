{
  config,
  lib,
  ...
}:
with lib;
with lib.internal; let
  cfg = config.system.time;
in {
  options.system.time = with types; {
    enable = mkBoolOpt false "Whether or not to configure timezone information.";
    timezone = mkOpt str "America/Denver" "Timezone to set for system";
  };

  config = mkIf cfg.enable {
    time.timeZone = cfg.timezone;
  };
}
