{
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.services.calendars;
in {
  options.glace.services.calendars = {
    enable = mkBoolOpt false "Whether to enable calendar synchronization via vdirsyncer.";
  };

  config = let
    outlookPasswordPath = "home/calendars/outlook/password";
  in
    mkIf cfg.enable {
      glace.services.davmail.enable = true;

      secrets.${outlookPasswordPath} = {};

      accounts.calendar = {
        basePath = "${config.xdg.configHome}/calendars";
        accounts = {
          outlook = {
            remote = {
              type = "caldav";
              url = "http://localhost:${toString config.glace.services.davmail.ports.caldav}";
              userName = "jaren.glenn@df-nn.com";
              passwordCommand = ["cat" config.sops.secrets.${outlookPasswordPath}.path];
            };
            local = {
              type = "filesystem";
              fileExt = ".ics";
            };
            vdirsyncer = {
              enable = true;
              collections = ["from a" "from b"];
              metadata = ["displayname" "color"];
            };
            khal = {
              enable = true;
              type = "discover";
              addresses = ["jaren.glenn@df-nn.com"];
            };
          };
        };
      };

      programs.khal = {
        enable = true;
        locale = {
          local_timezone = null;
          default_timezone = null;
        };
      };
      programs.vdirsyncer.enable = true;

      services.vdirsyncer = {
        enable = true;
        frequency = "*:0/5";
      };
    };
}
