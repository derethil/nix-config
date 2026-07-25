{self, ...}: {
  flake.modules.homeManager.postgresql-client = {
    config,
    lib,
    pkgs,
    ...
  }: let
    inherit (lib) concatMapStringsSep flatten listToAttrs unique;

    servers = [
      {
        database = "dragon_fire";
        hostSecret = "services/postgresql/dragonfire/test/host";
        name = "DragonFire [Test] [lambdauser]";
        passwordSecret = "services/postgresql/dragonfire/test/system_password";
        port = 5432;
        username = "lambdauser";
      }
      {
        database = "vigil";
        hostSecret = "services/postgresql/dragonfire/test/host";
        name = "Vigil [Test] [jarenglenn]";
        passwordSecret = "services/postgresql/dragonfire/test/personal_password";
        port = 5432;
        username = "jarenglenn";
      }
      {
        database = "vigil";
        hostSecret = "services/postgresql/dragonfire/test/host";
        name = "Vigil [Test] [lambdauser]";
        passwordSecret = "services/postgresql/dragonfire/test/system_password";
        port = 5432;
        username = "lambdauser";
      }
    ];

    secrets = unique (flatten (map (s: [s.hostSecret s.passwordSecret]) servers));

    passFilePath = "${config.home.homeDirectory}/.config/postgresql/pgpass";
  in {
    imports = [self.modules.homeManager.secrets];

    home = {
      packages = with pkgs; [
        postgresql18Packages.postgis
        postgresql_18
      ];

      sessionVariables.PGPASSFILE = passFilePath;
    };

    sops = {
      secrets = listToAttrs (map (s: {
          name = s;
          value = {};
        })
        secrets);

      templates."pgpass" = {
        mode = "0600";
        content =
          concatMapStringsSep "\n" (
            s: "${config.sops.placeholder.${s.hostSecret}}:${toString s.port}:${s.database}:${s.username}:${config.sops.placeholder.${s.passwordSecret}}"
          )
          servers;
        path = passFilePath;
      };
    };
  };
}
