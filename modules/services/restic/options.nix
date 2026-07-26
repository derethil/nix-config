{lib, ...}: let
  inherit (lib) mkOption types;

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

  backupType = types.submodule {
    options = {
      exclude = mkOption {
        default = [];
        description = "restic exclude patterns.";
        type = types.listOf types.str;
      };

      onCalendar = mkOption {
        default = "03:00";
        description = "systemd OnCalendar expression for the backup timer.";
        type = types.str;
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
    };
  };
in {
  flake.modules.nixos.restic-options = {
    options.internal.homelab.backups = mkOption {
      default = {};
      description = "restic backup jobs; each feature registers its own.";
      type = types.attrsOf backupType;
    };
  };
}
