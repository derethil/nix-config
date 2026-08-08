{lib, ...}: let
  inherit (lib) mkOption types;

  sqliteType = types.submodule {
    options = {
      name = mkOption {
        description = "Name used for the dump file.";
        type = types.str;
      };

      path = mkOption {
        description = "Absolute path to the .db file on the host (e.g. via podmanVolume).";
        type = types.str;
      };
    };
  };

  postgresType = types.submodule {
    options = {
      container = mkOption {
        description = "Podman container running the Postgres server to dump.";
        type = types.str;
      };

      database = mkOption {
        description = "Database to dump.";
        type = types.str;
      };

      user = mkOption {
        description = "Postgres role used for the dump.";
        type = types.str;
      };
    };
  };

  restoreType = types.submodule {
    options = {
      startAfter = mkOption {
        default = [];
        description = "Systemd services to start after the restore completes.";
        type = types.listOf types.str;
      };

      startBefore = mkOption {
        default = [];
        description = "Systemd services to start before data is written (e.g. a database container that pg_restore connects to).";
        type = types.listOf types.str;
      };

      stopServices = mkOption {
        default = [];
        description = "Systemd services to stop before restore.";
        type = types.listOf types.str;
      };
    };
  };

  backupType = types.submodule {
    options = {
      exclude = mkOption {
        default = [];
        description = "restic exclude patterns.";
        type = types.listOf types.str;
      };

      paths = mkOption {
        default = [];
        description = "Absolute paths to back up.";
        type = types.listOf types.str;
      };

      postgres = mkOption {
        default = [];
        description = "Postgres databases to dump via podman exec and include in the backup.";
        type = types.listOf postgresType;
      };

      prepareCommand = mkOption {
        default = "";
        description = "Extra shell run before the backup (e.g. custom dumps).";
        type = types.lines;
      };

      restore = mkOption {
        default = {};
        description = "Restore configuration for this backup job.";
        type = restoreType;
      };

      sqlite = mkOption {
        default = [];
        description = "SQLite databases to dump via sqlite3 .backup on the host and include in the backup.";
        type = types.listOf sqliteType;
      };
    };
  };
in {
  flake.modules.nixos.restic-options = {
    options.internal.homelab = {
      backups = mkOption {
        default = {};
        description = "restic backup jobs; each feature registers its own.";
        type = types.attrsOf backupType;
      };

      restic.retryLock = mkOption {
        default = "30m";
        description = "Duration to retry acquiring the restic repository lock before giving up.";
        type = types.str;
      };
    };
  };
}
