{
  flake.modules = {
    nixos.nh = {config, ...}: {
      programs.nh = {
        enable = true;

        clean = {
          enable = true;
          extraArgs = "--keep-since 7d --keep 3";
        };

        flake = config.internal.flakeRoot;
      };
    };

    darwin.nh = {
      config,
      lib,
      pkgs,
      ...
    }: {
      environment = {
        systemPackages = [pkgs.nh];
        variables.NH_FLAKE = config.internal.flakeRoot;
      };

      launchd.daemons.nh-clean = {
        script = "${lib.getExe pkgs.nh} clean all --keep-since 7d --keep 3";

        serviceConfig = {
          Label = "nh-clean";
          LowPriorityBackgroundIO = true;
          LowPriorityIO = true;
          ProcessType = "Background";
          StandardErrorPath = "/var/log/nh-clean.log";
          StandardOutPath = "/var/log/nh-clean.log";

          StartCalendarInterval = [
            {
              Hour = 0;
              Minute = 0;
              Weekday = 0;
            }
          ];

          StartOnMount = true;
        };
      };
    };
  };
}
