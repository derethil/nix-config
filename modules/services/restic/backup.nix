{lib, ...}: {
  flake.modules.nixos.restic-backup = {
    config,
    pkgs,
    ...
  }: let
    inherit (lib) concatMapStringsSep flatten getExe' mapAttrs;

    cfg = config.internal.homelab.backups;

    stagingRoot = "/var/lib/restic/staging";

    podman = getExe' pkgs.podman "podman";
    curl = getExe' pkgs.curl "curl";

    stagingDir = name: "${stagingRoot}/${name}";
    dumpFile = name: pg: "${stagingDir name}/${pg.container}-${pg.database}.dump";

    dumpCommands = name: job:
      concatMapStringsSep "\n"
      (pg: ''
        echo "==> Dumping ${pg.database}..."
        ${podman} exec ${pg.container} pg_dump -U ${pg.user} -Fc ${pg.database} > ${dumpFile name pg}'')
      job.postgres;

    ping = name: suffix: "${curl} -fsS -m 10 --retry 3 \"$HC_PING_URL/${name}-backup${suffix}?create=1\" || true";

    prepareScript = name: job:
      pkgs.writeShellScript "restic-prepare-${name}-backup" ''
        set -euo pipefail
        on_error() { ${ping name "/fail"}; }
        trap on_error ERR
        echo "==> Preparing ${name} backup..."
        ${ping name "/start"}
        rm -rf ${stagingDir name}
        mkdir -p ${stagingDir name}
        ${job.prepareCommand}
        ${dumpCommands name job}
      '';

    cleanupScript = name:
      pkgs.writeShellScript "restic-cleanup-${name}-backup" ''
        rm -rf ${stagingDir name}
        if [ "$EXIT_STATUS" = "0" ]; then
          ${ping name ""}
        else
          ${ping name "/fail"}
        fi
      '';
  in {
    config = {
      environment.systemPackages = [pkgs.restic pkgs.backblaze-b2];

      services.restic.backups =
        mapAttrs (
          name: job: {
            inherit (job) exclude;
            backupCleanupCommand = "${cleanupScript name}";
            backupPrepareCommand = "${prepareScript name job}";
            environmentFile = config.sops.templates."restic-env".path;
            extraBackupArgs = ["--retry-lock" config.internal.homelab.restic.retryLock "--tag" name];
            initialize = true;
            passwordFile = config.sops.secrets."services/restic/repository_password".path;

            paths = flatten [
              (map (pg: dumpFile name pg) job.postgres)
              job.paths
            ];

            repositoryFile = config.sops.secrets."services/restic/repository".path;
            # restic-nightly controls the timer for all jobs, so we don't want to create a timer for each job
            timerConfig = null;
          }
        )
        cfg;
    };
  };
}
