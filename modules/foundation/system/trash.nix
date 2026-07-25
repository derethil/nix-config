{
  self,
  lib,
  ...
}: let
  inherit (lib) getExe mkIf mkMerge;
in {
  flake.modules.homeManager = {
    trash = {pkgs, ...}: {
      imports = [
        self.modules.homeManager.shell-consumer
        self.modules.homeManager.trash-timer
      ];

      home.packages = [
        pkgs.gtrash
      ];

      shell.aliases.del = "gtrash put";
    };

    trash-timer = {pkgs, ...}:
      mkMerge [
        # NOTE: launchd services are skipped if powered off. If asleep, it'll run on wake
        (mkIf pkgs.stdenv.hostPlatform.isDarwin {
          launchd.agents."trash-timer".config = {
            ProgramArguments = [(getExe pkgs.gtrash) "--day" "30" "prune"];

            StartCalendarInterval = {
              Hour = 0;
              Minute = 0;
              Weekday = 0;
            };
          };
        })
        (mkIf pkgs.stdenv.hostPlatform.isLinux {
          systemd.user = {
            services."trash-timer" = {
              Service = {
                ExecStart = "${getExe pkgs.gtrash} prune --day 30";
                Type = "oneshot";
              };

              Unit.Description = "Prune trash files older than 30 days";
            };

            timers."trash-timer" = {
              Install.WantedBy = ["timers.target"];

              Timer = {
                OnCalendar = "weekly";
                Persistent = true;
              };

              Unit.Description = "Timer for pruning trash files older than 30 days";
            };
          };
        })
      ];
  };
}
