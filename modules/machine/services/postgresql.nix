{lib, ...}: {
  flake.modules.nixos.postgresql = {
    config,
    pkgs,
    ...
  }: let
    inherit (lib) mkOption types flatten concatMapStringsSep optionalString mkAfter getExe';
    cfg = config.internal.services.postgresql;

    pkg = pkgs.unstable.postgresql_18;

    userType = types.submodule {
      options = {
        name = mkOption {
          type = types.str;
          description = "Username.";
        };
        passwordFile = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = "Path to a file containing the user's password. Read at service start.";
        };
        extraSettings = mkOption {
          type = types.attrs;
          default = {};
          description = "Extra attributes merged into services.postgresql.ensureUsers.<this>.";
        };
      };
    };

    databaseType = types.submodule {
      options = {
        name = mkOption {
          type = types.str;
          description = "Database name.";
        };
        owner = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = "Database owner.";
        };
        users = mkOption {
          type = types.listOf userType;
          default = [];
          description = "Users granted access to this database.";
        };
      };
    };

    users = flatten (map (db: db.users) cfg.databases);
  in {
    options.internal.services.postgresql = {
      user.extraGroups = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "Additional groups to add the postgres system user to (useful for reading password files).";
      };

      databases = mkOption {
        type = types.listOf databaseType;
        default = [];
        description = "Databases to create on service start.";
      };
    };

    config = {
      services.postgresql = {
        enable = true;
        package = pkg;
        ensureDatabases = map (db: db.name) cfg.databases;
        ensureUsers = map (user: {inherit (user) name;} // user.extraSettings) users;
      };

      users.users.postgres.extraGroups = cfg.user.extraGroups;

      # Set initial passwords from files on first start. Adapted from
      # https://github.com/NixOS/nixpkgs/pull/326306
      systemd.services.postgresql.postStart = mkAfter (
        concatMapStringsSep "\n" (
          user: let
            setPassword = pkgs.writeText "set-pw.sql" ''
              DO $$
              DECLARE password TEXT;
              BEGIN
                password := trim(both from replace(pg_read_file('${user.passwordFile}'), E'\n', '''));
                EXECUTE 'ALTER ROLE "${user.name}" WITH PASSWORD' || quote_literal(password);
              END $$;
            '';
          in
            optionalString (user.passwordFile != null) "${getExe' pkg "psql"} -tAf ${setPassword}"
        )
        users
      );

      internal.boot.impermanence.extraDirectories = [
        "/var/lib/postgresql/${config.services.postgresql.package.psqlSchema}"
      ];
    };
  };
}
