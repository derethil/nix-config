{self, ...}: {
  flake-file.inputs.khal-notify = {
    inputs.nixpkgs.follows = "nixpkgs";
    url = "github:martiert/khal_notifications";
  };

  flake.modules.homeManager.calendars = {
    config,
    lib,
    pkgs,
    ...
  }: let
    inherit (lib) attrNames concatMapStringsSep getExe;
    outlookPasswordPath = "accounts/calendars/outlook/password";
  in {
    imports = with self.modules.homeManager; [
      davmail
      secrets
    ];

    accounts.calendar = {
      accounts = {
        holidays = {
          khal = {
            enable = true;
            readOnly = true;
          };

          local = {
            fileExt = ".ics";
            type = "filesystem";
          };

          remote = {
            type = "http";
            url = "https://www.calendarlabs.com/ical-calendar/ics/76/US_Holidays.ics";
          };

          vdirsyncer = {
            enable = true;
            collections = null;
          };
        };

        outlook = {
          khal = {
            enable = true;
            addresses = ["jaren.glenn@df-nn.com"];
            type = "discover";
          };

          local = {
            fileExt = ".ics";
            type = "filesystem";
          };

          remote = {
            passwordCommand = ["cat" config.sops.secrets.${outlookPasswordPath}.path];
            type = "caldav";
            url = "http://localhost:${toString config.internal.davmail.caldavPort}";
            userName = "jaren.glenn@df-nn.com";
          };

          vdirsyncer = {
            enable = true;
            collections = ["from a" "from b"];
            metadata = ["color" "displayname"];
          };
        };
      };

      basePath = "${config.xdg.dataHome}/calendars";
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

    programs = {
      khal = {
        enable = true;

        locale = {
          default_timezone = null;
          local_timezone = null;
        };
      };

      vdirsyncer.enable = true;
    };

    services.vdirsyncer = {
      enable = true;
      frequency = "*:0/5";
    };

    sops.secrets.${outlookPasswordPath} = {};

    systemd.user = {
      services.khal-notify = {
        Service = {
          ExecStart = "${pkgs.inputs.khal-notify.default}/bin/khal-notify";
          Type = "oneshot";
        };

        Unit = {
          After = ["graphical-session.target" "network.target"];
          Description = "Khal calendar notification service";
        };
      };

      timers.khal-notify = {
        Install.WantedBy = ["graphical-session.target" "timers.target"];
        Timer.OnCalendar = "*:0/1";
        Unit.Description = "Khal calendar notification timer";
      };
    };
  };
}
