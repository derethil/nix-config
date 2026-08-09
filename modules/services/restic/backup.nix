{
  self,
  lib,
  ...
}: {
  flake.modules.nixos.restic-backup = {
    config,
    pkgs,
    ...
  }: let
    inherit (lib) concatMapStringsSep flatten getExe' mapAttrs;

    cfg = config.internal.homelab.backups;

    stagingRoot = "/var/lib/restic/staging";

    podman = getExe' pkgs.podman "podman";
    sqlite3 = getExe' pkgs.sqlite "sqlite3";

    stagingDir = name: "${stagingRoot}/${name}";
    dumpFile = name: pg: "${stagingDir name}/${pg.container}-${pg.database}.dump";
    sqliteDumpFile = name: db: "${stagingDir name}/${db.name}.db";

    ping = {
      name,
      success,
      error ? null,
    }:
      self.lib.gatus.mkPush {
        inherit error name pkgs success;
        group = "backups";
      };

    dumpCommands = name: job:
      concatMapStringsSep "\n"
      (pg: ''
        echo "==> Dumping ${pg.database}..."
        ${podman} exec ${pg.container} pg_dump -U ${pg.user} -Fc ${pg.database} > ${dumpFile name pg}'')
      job.databases.postgres;

    sqliteDumpCommands = name: job:
      concatMapStringsSep "\n"
      (db: ''
        echo "==> Dumping SQLite ${db.name}..."
        ${sqlite3} "${db.path}" ".backup '${sqliteDumpFile name db}'"'')
      job.databases.sqlite;

    prepareScript = name: job:
      pkgs.writeShellScript "restic-prepare-${name}-backup" ''
        set -euo pipefail

        echo "==> Preparing ${name} backup..."
        rm -rf ${stagingDir name}

        mkdir -p ${stagingDir name}
        date +%s%3N > ${stagingDir name}/start_time_ms

        ${job.hooks.before}
        ${dumpCommands name job}
        ${sqliteDumpCommands name job}
      '';

    cleanupScript = name:
      pkgs.writeShellScript "restic-cleanup-${name}-backup" ''
        set -euo pipefail

        START_TIME_MS=$(cat ${stagingDir name}/start_time_ms || date +%s%3N)
        NOW=$(date +%s%3N)
        DURATION=$(( NOW - START_TIME_MS ))

        rm -rf ${stagingDir name}

        if [ "$EXIT_STATUS" = "0" ]; then
          ${ping {
          inherit name;
          success = true;
        }} --duration "$DURATION"ms
        else
          ${ping {
          inherit name;
          error = "restic backup failed for ${name} (exit $EXIT_STATUS)";
          success = false;
        }} --duration "$DURATION"ms
        fi
      '';
  in {
    config.services.restic.backups =
      mapAttrs (
        name: job: {
          inherit (job.files) exclude;
          backupCleanupCommand = "${cleanupScript name}";
          backupPrepareCommand = "${prepareScript name job}";
          environmentFile = config.sops.templates."restic-env".path;
          extraBackupArgs = ["--retry-lock" config.internal.homelab.restic.retryLock "--tag" name];
          initialize = true;
          passwordFile = config.sops.secrets."services/restic/repository_password".path;

          paths = flatten [
            (map (pg: dumpFile name pg) job.databases.postgres)
            (map (db: sqliteDumpFile name db) job.databases.sqlite)
            job.files.paths
          ];

          repositoryFile = config.sops.secrets."services/restic/repository".path;
          # restic-nightly controls the timer for all jobs, so we don't want to create a timer for each job
          timerConfig = null;
        }
      )
      cfg;
  };
}
