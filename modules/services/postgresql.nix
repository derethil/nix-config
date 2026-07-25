{lib, ...}: {
  flake.modules.nixos.postgresql = {
    config,
    pkgs,
    ...
  }: let
    inherit (lib) concatMapStringsSep flatten getExe' mkAfter mkOption optionalString types;
    cfg = config.internal.services.postgresql;

    pkg = pkgs.unstable.postgresql_18;

    userType = types.submodule {
      options = {
        extraSettings = mkOption {
          default = {};
          description = "Extra attributes merged into services.postgresql.ensureUsers.<this>.";
          type = types.attrs;
        };

        name = mkOption {
          description = "Username.";
          type = types.str;
        };

        passwordFile = mkOption {
          default = null;
          description = "Path to a file containing the user's password. Read at service start.";
          type = types.nullOr types.str;
        };
      };
    };

    databaseType = types.submodule {
      options = {
        name = mkOption {
          description = "Database name.";
          type = types.str;
        };

        owner = mkOption {
          default = null;
          description = "Database owner.";
          type = types.nullOr types.str;
        };

        users = mkOption {
          default = [];
          description = "Users granted access to this database.";
          type = types.listOf userType;
        };
      };
    };

    users = flatten (map (db: db.users) cfg.databases);
  in {
    options.internal.services.postgresql = {
      databases = mkOption {
        default = [];
        description = "Databases to create on service start.";
        type = types.listOf databaseType;
      };

      user.extraGroups = mkOption {
        default = [];
        description = "Additional groups to add the postgres system user to (useful for reading password files).";
        type = types.listOf types.str;
      };
    };

    config = {
      internal.boot.impermanence.extraDirectories = [
        "/var/lib/postgresql/${config.services.postgresql.package.psqlSchema}"
      ];

      services.postgresql = {
        enable = true;
        package = pkg;
        ensureDatabases = map (db: db.name) cfg.databases;
        ensureUsers = map (user: {inherit (user) name;} // user.extraSettings) users;
      };

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

      users.users.postgres.extraGroups = cfg.user.extraGroups;
    };
  };
}
