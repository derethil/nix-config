{lib, ...}: {
  flake.modules.nixos.restic-maintenance = {
    config,
    pkgs,
    ...
  }: let
    inherit (lib) attrNames concatMapStringsSep getExe getExe' mkIf;

    cfg = config.internal.homelab.backups;

    restic = getExe pkgs.restic;
    curl = getExe' pkgs.curl "curl";
    date = getExe' pkgs.coreutils "date";
    retryLock = config.internal.homelab.restic.retryLock;

    backupUnits = map (name: "restic-backups-${name}.service") (attrNames cfg);

    ping = suffix: ''${curl} -fsS -m 10 --retry 3 "$HC_PING_URL/nightly${suffix}?create=1" || true'';

    runScript = pkgs.writeShellScript "restic-nightly" ''
      set -uo pipefail
      status=0

      ${ping "/start"}

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

      if [ "$status" = 0 ]; then ${ping ""}; else ${ping "/fail"}; fi
      exit $status
    '';
  in {
    config = mkIf (cfg != {}) {
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
