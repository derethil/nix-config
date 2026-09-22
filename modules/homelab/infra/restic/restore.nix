{lib, ...}: {
  flake.modules.nixos.restic-restore = {
    config,
    pkgs,
    ...
  }: let
    inherit (lib) concatMapStringsSep concatStringsSep getExe getExe' mapAttrsToList optionalString;

    cfg = config.internal.homelab.backups;

    stagingRoot = "/var/lib/restic/staging";

    bash = getExe pkgs.bash;
    podman = getExe' pkgs.podman "podman";
    restic = getExe pkgs.restic;
    sqlite3 = getExe' pkgs.sqlite "sqlite3";

    stagingDir = name: "${stagingRoot}/${name}";
    dumpFile = name: pg: "${stagingDir name}/${pg.container}-${pg.database}.dump";
    sqliteDumpFile = name: db: "${stagingDir name}/${db.name}.db";

    resticEnv = ''
      set -a
      source ${config.sops.templates."restic-env".path}
      set +a
      export RESTIC_REPOSITORY_FILE=${config.sops.secrets."services/restic/repository".path}
      export RESTIC_PASSWORD_FILE=${config.sops.secrets."services/restic/repository_password".path}
      export RESTIC_CACHE_DIR=/var/lib/restic/cache
    '';

    restoreScript = name: job: let
      hasFiles = job.files.paths != [];
      hasDbs = builtins.any (dbs: dbs != []) (builtins.attrValues job.databases);

      sqliteRestoreCmds = concatMapStringsSep "\n" (db: ''
        if ! sudo test -s "${sqliteDumpFile name db}"; then
          echo "==> ERROR: SQLite dump for ${db.name} is missing or empty; refusing to restore" >&2
          exit 1
        fi

        echo "==> Restoring SQLite ${db.name}..."
        sudo ${sqlite3} "${db.path}" ".restore '${sqliteDumpFile name db}'"'')
      job.databases.sqlite;

      pgRestoreCmds = concatMapStringsSep "\n" (pg: ''
        if ! sudo test -s "${dumpFile name pg}"; then
          echo "==> ERROR: dump for ${pg.database} is missing or empty; refusing to --clean the live database" >&2
          exit 1
        fi

        echo "==> Waiting for ${pg.container}..."
        until timeout 2 sudo ${podman} exec ${pg.container} pg_isready -U ${pg.user} &>/dev/null; do sleep 1; done
        echo "==> Restoring ${pg.database}..."
        sudo cat "${dumpFile name pg}" \
            | sudo ${podman} exec -i ${pg.container} pg_restore -U ${pg.user} -d ${pg.database} --clean --if-exists --single-transaction'')
      job.databases.postgres;
    in
      pkgs.writeShellScriptBin "restic-restore-${name}" ''
        set -euo pipefail
        snapshot="''${1:-latest}"

        ${optionalString (job.restore.services.stop != []) ''
          echo "==> Stopping services..."
          sudo systemctl stop ${concatStringsSep " " job.restore.services.stop}
        ''}

        ${optionalString (job.restore.hooks.afterStop != "") ''
          echo "==> Running afterStop hooks..."
          ${job.restore.hooks.afterStop}
        ''}

        ${optionalString hasDbs "trap 'sudo rm -rf ${stagingDir name}' EXIT"}

        ${optionalString (hasFiles || hasDbs) ''
          echo "==> Restoring $snapshot..."
          sudo ${bash} -c '
            set -euo pipefail
            ${resticEnv}
            exec ${restic} restore "$1" --tag ${name} --overwrite if-changed --target /
          ' restic-restore "$snapshot"
        ''}

        ${optionalString (job.restore.hooks.afterSync != "") ''
          echo "==> Running afterSync hooks..."
          ${job.restore.hooks.afterSync}
        ''}

        ${optionalString (job.restore.services.afterSync != []) "sudo systemctl start ${concatStringsSep " " job.restore.services.afterSync}"}

        ${optionalString (job.databases.sqlite != []) sqliteRestoreCmds}

        ${optionalString (job.databases.postgres != []) pgRestoreCmds}

        ${optionalString (job.restore.services.afterRestore != []) ''
          echo "==> Starting services..."
          sudo systemctl start ${concatStringsSep " " job.restore.services.afterRestore}
        ''}

        ${optionalString (job.restore.hooks.afterRestore != "") ''
          echo "==> Running afterRestore hooks..."
          ${job.restore.hooks.afterRestore}
        ''}

        echo "==> Done."
      '';
  in {
    config.environment.systemPackages = mapAttrsToList restoreScript cfg;
  };
}
