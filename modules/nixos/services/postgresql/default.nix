{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf types flatten concatMapStringsSep optionalString mkAfter getExe';
  inherit (lib.glace) mkBoolOpt mkSubmoduleListOpt mkOpt mkNullableOpt;
  cfg = config.glace.services.postgresql;
in {
  options.glace.services.postgresql = with types; {
    enable = mkBoolOpt false "Whether to enable PostgreSQL server.";

    user = {
      extraGroups = mkOpt (listOf str) [] "Additional groups to add the postgres user to for reading password files.";
    };

    databases = mkSubmoduleListOpt "Databases to create." {
      name = mkOpt str null "Database name.";
      owner = mkOpt (nullOr str) null "Database owner.";
      users = mkSubmoduleListOpt "Users for this database." {
        name = mkOpt str null "Username.";
        passwordFile = mkNullableOpt str null "The path to a file containing a password that is to be set as the user's PASSWORD field.";
        extraSettings = mkOpt attrs {} "Extra settings to pass to <option>services.postgresql.ensureUsers.<user></option>.";
      };
    };
  };

  config = let
    users = flatten (map (db: db.users) cfg.databases);
  in
    mkIf cfg.enable {
      services.postgresql = {
        enable = true;
        package = pkgs.postgresql_18;
        ensureDatabases = map (db: db.name) cfg.databases;
        ensureUsers = map (user:
          {
            inherit (user) name;
          }
          // user.extraSettings)
        users;
      };

      users.users.postgres.extraGroups = cfg.user.extraGroups;

      # NOTE: Taken from: https://github.com/NixOS/nixpkgs/pull/326306
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
            optionalString (user.passwordFile != null) "${getExe' pkgs.postgresql_18 "psql"} -tAf ${setPassword}"
        )
        users
      );

      glace.system.impermanence.extraDirectories = [
        "/var/lib/postgresql/${config.services.postgresql.package.psqlSchema}"
      ];
    };
}
