{lib, ...}: {
  flake.modules.nixos.restic-restore = {
    config,
    pkgs,
    ...
  }: let
    inherit (lib) concatMapStringsSep concatStringsSep filter flatten getExe getExe' hasPrefix mapAttrsToList optional optionalString removePrefix removeSuffix;

    cfg = config.internal.homelab.backups;

    stagingRoot = "/var/lib/restic/staging";

    bash = getExe pkgs.bash;
    podman = getExe' pkgs.podman "podman";
    restic = getExe pkgs.restic;
    rsync = getExe' pkgs.rsync "rsync";
    sqlite3 = getExe' pkgs.sqlite "sqlite3";

    stagingDir = name: "${stagingRoot}/${name}";
    dumpFile = name: pg: "${stagingDir name}/${pg.container}-${pg.database}.dump";
    sqliteDumpFile = name: db: "${stagingDir name}/${db.name}.db";

    restoreScript = name: job: let
      restoreArgs = flatten [
        "--tag ${name}"
        (map (p: "--include ${removeSuffix "/_data" p}") job.files.paths)
        (optional (job.databases.postgres != [] || job.databases.sqlite != []) "--include ${stagingRoot}/${name}")
      ];

      rsyncExcludeArgs = p:
        concatMapStringsSep " " (
          e:
            if hasPrefix "${p}/" e
            then ''--exclude "${removePrefix p e}"''
            else ''--exclude "${e}"''
        )
        (filter (e: hasPrefix "${p}/" e || !hasPrefix "/" e) job.files.exclude);

      rsyncCmds =
        concatMapStringsSep "\n" (p: ''
          if ! sudo test -d "$tmp${p}" || [ -z "$(sudo ls -A "$tmp${p}")" ]; then
            echo "==> ERROR: restic restored nothing to $tmp${p}; refusing to rsync --delete into ${p}" >&2
            exit 1
          fi

          sudo mkdir -p "${p}"
          sudo ${rsync} -a --delete ${rsyncExcludeArgs p} "$tmp${p}/" "${p}/"
        '')
        job.files.paths;

      sqliteRestoreCmds = concatMapStringsSep "\n" (db: ''
        if ! sudo test -s "$tmp${sqliteDumpFile name db}"; then
          echo "==> ERROR: SQLite dump for ${db.name} is missing or empty; refusing to restore" >&2
          exit 1
        fi

        echo "==> Restoring SQLite ${db.name}..."
        sudo ${sqlite3} "${db.path}" ".restore '$tmp${sqliteDumpFile name db}'"'')
      job.databases.sqlite;

      pgRestoreCmds = concatMapStringsSep "\n" (pg: ''
        if ! sudo test -s "$tmp${dumpFile name pg}"; then
          echo "==> ERROR: dump for ${pg.database} is missing or empty; refusing to --clean the live database" >&2
          exit 1
        fi

        echo "==> Waiting for ${pg.container}..."
        until timeout 2 sudo ${podman} exec ${pg.container} pg_isready -U ${pg.user} &>/dev/null; do sleep 1; done
        echo "==> Restoring ${pg.database}..."
        sudo cat "$tmp${dumpFile name pg}" \
            | sudo ${podman} exec -i ${pg.container} pg_restore -U ${pg.user} -d ${pg.database} --clean --if-exists --single-transaction'')
      job.databases.postgres;
    in
      pkgs.writeShellScriptBin "restic-restore-${name}" ''
        set -euo pipefail
        snapshot="''${1:-latest}"

        # restic restores files into $tmp as root so it can preserve the
        # original uid/gid; everything touching $tmp afterwards needs sudo.
        tmp=$(mktemp -d)
        trap 'sudo rm -rf "$tmp"' EXIT

        ${optionalString (job.restore.services.stop != []) ''
          echo "==> Stopping services..."
          sudo systemctl stop ${concatStringsSep " " job.restore.services.stop}
        ''}

        ${optionalString (job.restore.hooks.afterStop != "") ''
          echo "==> Running afterStop hooks..."
          ${job.restore.hooks.afterStop}
        ''}

        echo "==> Restoring $snapshot..."
        # Run restic as root so it restores the original ownership. Secrets are
        # read from files by root, so they never touch our env or any argv.
        sudo ${bash} -c '
          set -euo pipefail
          set -a
          source ${config.sops.templates."restic-env".path}
          set +a
          export RESTIC_REPOSITORY_FILE=${config.sops.secrets."services/restic/repository".path}
          export RESTIC_PASSWORD_FILE=${config.sops.secrets."services/restic/repository_password".path}
          export RESTIC_CACHE_DIR=/var/lib/restic/cache
          exec ${restic} restore "$1" \
            ${concatStringsSep " " restoreArgs} \
            --target "$2"
        ' restic-restore "$snapshot" "$tmp"

        echo "==> Syncing volumes..."
        ${rsyncCmds}

        ${optionalString (job.restore.hooks.afterSync != "") ''
          echo "==> Running afterSync hooks..."
          ${job.restore.hooks.afterSync}
        ''}

        ${optionalString (job.restore.services.afterSync != []) "sudo systemctl start ${concatStringsSep " " job.restore.services.afterSync}"}

        ${sqliteRestoreCmds}

        ${pgRestoreCmds}

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
