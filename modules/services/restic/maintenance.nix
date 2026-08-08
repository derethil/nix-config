{
  self,
  lib,
  ...
}: {
  flake.modules.nixos.restic-maintenance = {
    config,
    pkgs,
    ...
  }: let
    inherit (lib) attrNames concatMapStringsSep getExe getExe' mapAttrs mkIf mkMerge;

    backupCfg = config.internal.homelab.backups;

    restic = getExe pkgs.restic;
    date = getExe' pkgs.coreutils "date";
    retryLock = config.internal.homelab.restic.retryLock;

    backupUnits = map (name: "restic-backups-${name}.service") (attrNames backupCfg);

    ping = {
      success,
      error ? null,
    }:
      self.lib.gatus.mkPush {
        inherit error pkgs success;
        group = "backups";
        name = "nightly";
      };

    runScript = pkgs.writeShellScript "restic-nightly" ''
      set -uo pipefail
      status=0

      START_TIME_MS=$(date +%s%3N)

      ${concatMapStringsSep "\n" (unit: ''
          echo "==> Backing up ${unit}..."
          systemctl start --wait ${unit} || { echo "==> WARN: ${unit} failed" >&2; status=1; }
        '')
        backupUnits}

      echo "==> Forgetting + pruning..."
      ${restic} unlock || true
      ${restic} forget --prune --group-by tags \
        --keep-last 1 --keep-daily 7 --keep-monthly 6 --keep-weekly 4 \
        --retry-lock ${retryLock} || status=1

      # Verify a deterministic 1/7 slice of the pack data, keyed off day-of-week
      subset="$(${date} +%u)/7"
      echo "==> Checking repository (read-data subset ''${subset})..."
      ${restic} check --retry-lock ${retryLock} --read-data-subset="''${subset}" || status=1

      DURATION_MS=$(($(date +%s%3N) - START_TIME_MS))

      if [ "$status" = 0 ]; then
        ${ping {success = true;}} --duration "$DURATION_MS"ms
      else
        ${ping {
        error = "nightly restic run failed (a backup job, prune, or repository check failed)";
        success = false;
      }} --duration "$DURATION"ms
      fi
      exit $status
    '';

    gatusEndpoint = {
      group = "backups";
      heartbeatInterval = "25h";
    };
  in {
    config = mkIf (backupCfg != {}) {
      internal.homelab.gatus.externalEndpoints = mkMerge [
        (mapAttrs (_: _: gatusEndpoint) backupCfg)
        {nightly = gatusEndpoint;}
      ];

      systemd = {
        services.restic-nightly = {
          after = ["network-online.target"];
          description = "Back up all restic jobs in sequence, then prune + check";

          serviceConfig = {
            Environment = [
              "RESTIC_REPOSITORY_FILE=${config.sops.secrets."services/restic/repository".path}"
              "RESTIC_PASSWORD_FILE=${config.sops.secrets."services/restic/repository_password".path}"
            ];

            EnvironmentFile = config.sops.templates."restic-env".path;
            ExecStart = runScript;
            Type = "oneshot";
          };

          wants = ["network-online.target"];
        };

        timers.restic-nightly = {
          timerConfig = {
            OnCalendar = "03:00";
            Persistent = true;
            RandomizedDelaySec = "15m";
          };

          wantedBy = ["timers.target"];
        };
      };
    };
  };
}
