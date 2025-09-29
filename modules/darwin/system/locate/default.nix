{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;

  cfg = config.glace.system.locate;
in {
  options.glace.system.locate = {
    enable = mkBoolOpt false "Whether to enable the locate database service.";
  };

  config = mkIf cfg.enable {
    launchd.daemons.locate = {
      serviceConfig = {
        Label = "com.apple.locate";
        ProgramArguments = ["/usr/libexec/locate.updatedb"];
        StartCalendarInterval = [{Hour = 3;}];
        StartOnMount = true;
        Nice = 5;
      };
    };
  };
}
