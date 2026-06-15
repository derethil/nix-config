{lib, ...}: {
  flake.modules.homeManager.remote-pull = {
    config,
    pkgs,
    ...
  }: let
    inherit (lib) mkOption types listToAttrs optionalString;

    targetType = types.submodule {
      options = {
        name = mkOption {
          type = types.str;
          description = "Unique identifier for this backup target. Drives the systemd unit name.";
        };
        source = mkOption {
          type = types.str;
          description = "Remote source path, e.g. user@host:/path/to/dir.";
        };
        destination = mkOption {
          type = types.str;
          description = "Local destination path.";
        };
        schedule = mkOption {
          type = types.str;
          default = "daily";
          description = "Systemd calendar expression for when to run the pull.";
        };
        delete = mkOption {
          type = types.bool;
          default = false;
          description = "If true, wipe the destination before moving the freshly pulled files into place.";
        };
      };
    };

    targets = config.internal.services.remote-pull.targets;

    makeService = target: {
      name = "remote-pull-${target.name}";
      value = {
        Unit = {
          Description = "rsync pull backup: ${target.name}";
          After = ["network.target"];
        };
        Service = {
          Type = "oneshot";
          ExecStart = pkgs.writeShellScript "remote-pull-${target.name}" ''
            tmp=$(mktemp -d)
            if ${pkgs.openssh}/bin/scp -r ${target.source} "$tmp"; then
              ${optionalString target.delete "rm -rf ${target.destination}/*"}
              mv "$tmp"/* ${target.destination}/
            fi
            rm -rf "$tmp"
          '';
        };
      };
    };

    makeTimer = target: {
      name = "remote-pull-${target.name}";
      value = {
        Unit.Description = "Timer for rsync pull backup: ${target.name}";
        Timer = {
          OnCalendar = target.schedule;
          Persistent = true;
        };
        Install.WantedBy = ["timers.target"];
      };
    };
  in {
    options.internal.services.remote-pull.targets = mkOption {
      type = types.listOf targetType;
      default = [];
      description = "Remote sources to pull via scp on a timer.";
    };

    config = {
      systemd.user.services = listToAttrs (map makeService targets);
      systemd.user.timers = listToAttrs (map makeTimer targets);
    };
  };
}
