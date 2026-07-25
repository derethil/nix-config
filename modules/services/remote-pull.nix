{lib, ...}: {
  flake.modules.homeManager.remote-pull = {
    config,
    pkgs,
    ...
  }: let
    inherit (lib) listToAttrs mkOption optionalString types;

    targetType = types.submodule {
      options = {
        delete = mkOption {
          default = false;
          description = "If true, wipe the destination before moving the freshly pulled files into place.";
          type = types.bool;
        };

        destination = mkOption {
          description = "Local destination path.";
          type = types.str;
        };

        name = mkOption {
          description = "Unique identifier for this backup target. Drives the systemd unit name.";
          type = types.str;
        };

        schedule = mkOption {
          default = "daily";
          description = "Systemd calendar expression for when to run the pull.";
          type = types.str;
        };

        source = mkOption {
          description = "Remote source path, e.g. user@host:/path/to/dir.";
          type = types.str;
        };
      };
    };

    targets = config.internal.services.remote-pull.targets;

    makeService = target: {
      name = "remote-pull-${target.name}";

      value = {
        Service = {
          ExecStart = pkgs.writeShellScript "remote-pull-${target.name}" ''
            tmp=$(mktemp -d)
            if ${pkgs.openssh}/bin/scp -r ${target.source} "$tmp"; then
              ${optionalString target.delete "rm -rf ${target.destination}/*"}
              mv "$tmp"/* ${target.destination}/
            fi
            rm -rf "$tmp"
          '';

          Type = "oneshot";
        };

        Unit = {
          After = ["network.target"];
          Description = "rsync pull backup: ${target.name}";
        };
      };
    };

    makeTimer = target: {
      name = "remote-pull-${target.name}";

      value = {
        Install.WantedBy = ["timers.target"];

        Timer = {
          OnCalendar = target.schedule;
          Persistent = true;
        };

        Unit.Description = "Timer for rsync pull backup: ${target.name}";
      };
    };
  in {
    options.internal.services.remote-pull.targets = mkOption {
      default = [];
      description = "Remote sources to pull via scp on a timer.";
      type = types.listOf targetType;
    };

    config.systemd.user = {
      services = listToAttrs (map makeService targets);
      timers = listToAttrs (map makeTimer targets);
    };
  };
}
