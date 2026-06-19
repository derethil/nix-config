{
  self,
  lib,
  ...
}: let
  inherit (lib) mkMerge mkIf getExe;
in {
  flake.modules.homeManager.trash = {pkgs, ...}: {
    imports = [
      self.modules.homeManager.shell-consumer
      self.modules.homeManager.trash-timer
    ];

    shell.aliases = {
      del = "gtrash put";
    };

    home.packages = [
      pkgs.gtrash
    ];
  };

  flake.modules.homeManager.trash-timer = {pkgs, ...}:
    mkMerge [
      (mkIf pkgs.stdenv.hostPlatform.isLinux {
        systemd.user.timers."trash-timer" = {
          Unit.Description = "Timer for pruning trash files older than 30 days";
          Install.WantedBy = ["timers.target"];
          Timer = {
            OnCalendar = "weekly";
            Persistent = true;
          };
        };

        systemd.user.services."trash-timer" = {
          Unit.Description = "Prune trash files older than 30 days";
          Service = {
            Type = "oneshot";
            ExecStart = "${getExe pkgs.gtrash} prune --day 30";
          };
        };
      })

      # NOTE: launchd services are skipped if powered off. If asleep, it'll run on wake
      (mkIf pkgs.stdenv.hostPlatform.isDarwin {
        launchd.agents."trash-timer".config = {
          ProgramArguments = [(getExe pkgs.gtrash) "prune" "--day" "30"];
          StartCalendarInterval = {
            Weekday = 0;
            Hour = 0;
            Minute = 0;
          };
        };
      })
    ];
}
