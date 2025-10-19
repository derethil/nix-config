{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) mkIf getExe getExe' attrNames concatMapStringsSep;
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

      # Calendars

      accounts.calendar = {
        basePath = "${config.xdg.dataHome}/calendars";
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

          holidays = {
            remote = {
              type = "http";
              url = "https://www.calendarlabs.com/ical-calendar/ics/76/US_Holidays.ics";
            };
            local = {
              type = "filesystem";
              fileExt = ".ics";
            };
            vdirsyncer = {
              enable = true;
              collections = null;
            };
            khal = {
              enable = true;
              readOnly = true;
            };
          };
        };
      };

      # Khal

      programs.khal = {
        enable = true;
        locale = {
          local_timezone = null;
          default_timezone = null;
        };
      };

      systemd.user.services.khal-notify = {
        Unit = {
          Description = "Khal calendar notification service";
          After = ["network.target" "graphical-session.target"];
        };
        Service = {
          Type = "oneshot";
          ExecStart = "${pkgs.inputs.khal-notify.default}/bin/khal-notify";
        };
      };

      systemd.user.timers.khal-notify = {
        Unit.Description = "Khal calendar notification timer";
        Timer.OnCalendar = "*:0/1";
        Install.WantedBy = ["timers.target" "graphical-session.target"];
      };

      # Vdirsyncer

      programs.vdirsyncer.enable = true;

      services.vdirsyncer = {
        enable = true;
        frequency = "*:0/5";
      };

      home.activation.vdirsyncerDiscover = let
        calendarAccounts = config.accounts.calendar.accounts;
        checkCalendars = concatMapStringsSep " || " (name: "[ ! -d \"$calendarsPath/${name}\" ]") (attrNames calendarAccounts);
      in
        config.lib.dag.entryAfter ["writeBoundary"] ''
          calendarsPath="${config.accounts.calendar.basePath}"
          if ${checkCalendars}; then
            echo "Running vdirsyncer discover for missing calendars..."
            $DRY_RUN_CMD ${getExe config.programs.vdirsyncer.package} discover || true
          else
            echo "All calendars exist, skipping vdirsyncer discover"
          fi
        '';
    };
}
