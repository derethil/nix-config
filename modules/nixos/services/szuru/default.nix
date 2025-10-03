{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf types;
  inherit (lib.glace) mkBoolOpt mkOpt;
  cfg = config.glace.services.szuru;
in {
  options.glace.services.szuru = {
    enable = mkBoolOpt false "Enable Szurubooru";
    port = mkOpt types.port 9000 "Port for the web interface";
  };

  config = let
    szuruSecretPath = "nixos/services/szurubooru";

    dataDir = "/var/lib/szurubooru";

    user = "szurubooru";
    group = "szurubooru";

    secret = {
      inherit group;
      owner = user;
      mode = "0440";
    };
  in
    mkIf cfg.enable {
      glace.services.postgresql = {
        enable = true;
        user.extraGroups = [group];
        databases = [
          {
            name = "szurubooru";
            owner = user;
            users = [
              {
                name = user;
                passwordFile = config.sops.secrets."${szuruSecretPath}/database_password".path;
                extraSettings.ensureDBOwnership = true;
              }
            ];
          }
        ];
      };
      secrets = {
        "${szuruSecretPath}/secret" = secret;
        "${szuruSecretPath}/database_password" = secret;
      };

      services.szurubooru = {
        enable = true;
        inherit user group dataDir;
        server.settings = {
          domain = "http://localhost:9000";
          delete_source_files = "yes";
          secretFile = config.sops.secrets."${szuruSecretPath}/secret".path;
        };
        database = {
          passwordFile = config.sops.secrets."${szuruSecretPath}/database_password".path;
        };
        client = {
          package = pkgs.szurubooru.client;
        };
      };

      services.nginx = {
        enable = true;
        virtualHosts."szuru.local" = {
          listen = [
            {
              addr = "0.0.0.0";
              port = cfg.port;
            }
          ];
          locations = {
            "~ ^/api$" = {
              return = "302 /api/";
            };
            "~ ^/api/(.*)$" = {
              extraConfig = ''
                if ($request_uri ~* "/api/(.*)") {
                  proxy_pass http://127.0.0.1:8080/$1;
                }
              '';
            };
            "/data/" = {
              alias = "${dataDir}/data/";
            };
            "/" = {
              tryFiles = "$uri /index.htm";
              root = "${pkgs.szurubooru.client}";
            };
          };
        };
      };

      glace.system.impermanence.extraDirectories = [dataDir];
    };
}
