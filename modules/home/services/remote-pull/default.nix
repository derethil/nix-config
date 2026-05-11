{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf types;
  inherit (lib.glace) mkBoolOpt mkOpt;
  cfg = config.glace.services.remote-pull;

  targetType = types.submodule {
    options = {
      name = mkOpt types.str "" "Unique name for this backup target.";
      source = mkOpt types.str "" "Remote source path (e.g. user@host:/path/to/dir).";
      destination = mkOpt types.str "" "Local destination path.";
      schedule = mkOpt types.str "daily" "Systemd calendar expression for the backup schedule.";
      delete = mkBoolOpt false "Whether to delete files at the destination that no longer exist at the source.";
    };
  };

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
            ${lib.optionalString target.delete "rm -rf ${target.destination}/*"}
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
  options.glace.services.remote-pull = {
    enable = mkBoolOpt false "Whether to enable remote rsync pull backups.";
    targets = mkOpt (types.listOf targetType) [] "List of remote backup targets.";
  };

  config = mkIf cfg.enable {
    systemd.user.services = builtins.listToAttrs (map makeService cfg.targets);
    systemd.user.timers = builtins.listToAttrs (map makeTimer cfg.targets);
  };
}
