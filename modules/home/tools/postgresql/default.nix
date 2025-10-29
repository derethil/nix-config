{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) types mkIf mkDefault concatMapStringsSep map;
  inherit (lib.glace) mkBoolOpt mkSubmoduleListOpt mkOpt;
  cfg = config.glace.tools.postgresql;
in {
  options.glace.tools.postgresql = with types; {
    enable = mkBoolOpt false "Whether to enable PostgreSQL client tools.";

    servers = mkSubmoduleListOpt "PostgreSQL server configurations." {
      name = mkOpt str null "Server name/alias.";
      hostSecret = mkOpt (nullOr str) null "SOPS secret path for hostname.";
      port = mkOpt port 5432 "PostgreSQL server port.";
      database = mkOpt str "postgres" "Default database name.";
      username = mkOpt str "postgres" "Default username.";
      passwordSecret = mkOpt (nullOr str) null "SOPS secret path for password.";
    };
  };

  config = mkIf cfg.enable (let
    allSecrets = lib.unique (lib.flatten (map (server: [
        (lib.optional (server.hostSecret != null) server.hostSecret)
        (lib.optional (server.passwordSecret != null) server.passwordSecret)
      ])
      cfg.servers));

    secretsConfig = lib.listToAttrs (map (secret: {
        name = secret;
        value = {};
      })
      allSecrets);
  in {
    secrets = secretsConfig;

    glace.tools.postgresql.servers = mkDefault [
      {
        name = "Vigil [Test] [jarenglenn]";
        hostSecret = "postgresql/dragonfire/test/host";
        database = "vigil";
        username = "jarenglenn";
        passwordSecret = "postgresql/dragonfire/test/personal_password";
      }
      {
        name = "DragonFire [Test] [lambdauser]";
        hostSecret = "postgresql/dragonfire/test/host";
        database = "dragon_fire";
        username = "lambdauser";
        passwordSecret = "postgresql/dragonfire/test/system_password";
      }
      {
        name = "Vigil [Test] [lambdauser]";
        hostSecret = "postgresql/dragonfire/test/host";
        database = "vigil";
        username = "lambdauser";
        passwordSecret = "postgresql/dragonfire/test/system_password";
      }
    ];

    home.packages = with pkgs.unstable; [
      postgresql_18
      postgresql18Packages.postgis
    ];

    sops.templates."pgpass" = mkIf (cfg.servers != []) {
      name = "pgpass";
      content =
        concatMapStringsSep "\n" (
          server: "${config.sops.placeholder."${server.hostSecret}"}:${toString server.port}:${server.database}:${server.username}:${config.sops.placeholder."${server.passwordSecret}"}"
        )
        cfg.servers;
      path = "${config.home.homeDirectory}/.config/postgresql/pgpass";
      mode = "0600";
    };

    home.sessionVariables = mkIf (cfg.servers != []) {
      PGPASSFILE = "$HOME/.config/postgresql/pgpass";
    };
  });
}
