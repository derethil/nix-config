{lib, ...}: let
  inherit (lib) mkOption types;

  sqliteType = types.submodule {
    options = {
      name = mkOption {
        description = "Name used for the dump file.";
        type = types.str;
      };

      path = mkOption {
        description = "Absolute path to the .db file on the host (e.g. via self.lib.podman.volume).";
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

  servicesType = types.submodule {
    options = {
      afterRestore = mkOption {
        default = [];
        description = "Systemd services to start after all restores complete.";
        type = types.listOf types.str;
      };

      afterSync = mkOption {
        default = [];
        description = "Systemd services to start after volumes are synced, before any database restores.";
        type = types.listOf types.str;
      };

      stop = mkOption {
        default = [];
        description = "Systemd services to stop before restore begins.";
        type = types.listOf types.str;
      };
    };
  };

  restoreType = types.submodule {
    options = {
      services = mkOption {
        default = {};
        description = "Systemd services to stop/start at specific points during the restore.";
        type = servicesType;
      };
    };
  };

  filesType = types.submodule {
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
    };
  };

  databasesType = types.submodule {
    options = {
      postgres = mkOption {
        default = [];
        description = "Postgres databases to dump via podman exec and include in the backup.";
        type = types.listOf postgresType;
      };

      sqlite = mkOption {
        default = [];
        description = "SQLite databases to dump via sqlite3 .backup on the host and include in the backup.";
        type = types.listOf sqliteType;
      };
    };
  };

  backupHooksType = types.submodule {
    options.before = mkOption {
      default = "";
      description = "Shell commands to run before dumps and the restic backup.";
      type = types.lines;
    };
  };

  backupType = types.submodule {
    options = {
      databases = mkOption {
        default = {};
        description = "Databases to dump and include in the backup.";
        type = databasesType;
      };

      files = mkOption {
        default = {};
        description = "Filesystem paths to include in the backup.";
        type = filesType;
      };

      hooks = mkOption {
        default = {};
        description = "Shell hooks to run at specific points during the backup.";
        type = backupHooksType;
      };

      restore = mkOption {
        default = {};
        description = "Restore configuration for this backup job.";
        type = restoreType;
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
