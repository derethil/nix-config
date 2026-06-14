{self, ...}: {
  flake.modules.homeManager.postgresql-client = {
    config,
    pkgs,
    lib,
    ...
  }: let
    inherit (lib) concatMapStringsSep unique flatten listToAttrs;

    servers = [
      {
        name = "Vigil [Test] [jarenglenn]";
        hostSecret = "services/postgresql/dragonfire/test/host";
        port = 5432;
        database = "vigil";
        username = "jarenglenn";
        passwordSecret = "services/postgresql/dragonfire/test/personal_password";
      }
      {
        name = "DragonFire [Test] [lambdauser]";
        hostSecret = "services/postgresql/dragonfire/test/host";
        port = 5432;
        database = "dragon_fire";
        username = "lambdauser";
        passwordSecret = "services/postgresql/dragonfire/test/system_password";
      }
      {
        name = "Vigil [Test] [lambdauser]";
        hostSecret = "services/postgresql/dragonfire/test/host";
        port = 5432;
        database = "vigil";
        username = "lambdauser";
        passwordSecret = "services/postgresql/dragonfire/test/system_password";
      }
    ];

    secrets = unique (flatten (map (s: [s.hostSecret s.passwordSecret]) servers));

    passFilePath = "${config.home.homeDirectory}/.config/postgresql/pgpass";
  in {
    imports = [self.modules.homeManager.secrets];

    sops.secrets = listToAttrs (map (s: {
        name = s;
        value = {};
      })
      secrets);

    sops.templates."pgpass" = {
      content =
        concatMapStringsSep "\n" (
          s: "${config.sops.placeholder.${s.hostSecret}}:${toString s.port}:${s.database}:${s.username}:${config.sops.placeholder.${s.passwordSecret}}"
        )
        servers;
      path = passFilePath;
      mode = "0600";
    };

    home.sessionVariables = {
      PGPASSFILE = passFilePath;
    };

    home.packages = with pkgs; [
      postgresql_18
      postgresql18Packages.postgis
    ];
  };
}
