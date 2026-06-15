{...}: {
  flake.modules.nixos.nh = {config, ...}: {
    programs.nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep-since 7d --keep 3";
      flake = config.internal.flakeRoot;
    };
  };

  flake.modules.darwin.nh = {
    config,
    pkgs,
    lib,
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
        ProcessType = "Background";
        StartCalendarInterval = [
          {
            Weekday = 0;
            Hour = 0;
            Minute = 0;
          }
        ];
        StartOnMount = true;
        LowPriorityIO = true;
        LowPriorityBackgroundIO = true;
        StandardOutPath = "/var/log/nh-clean.log";
        StandardErrorPath = "/var/log/nh-clean.log";
      };
    };
  };
}
