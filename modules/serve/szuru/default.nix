{
  self,
  lib,
  ...
}: {
  flake.modules.nixos.szuru = {
    config,
    pkgs,
    ...
  }: let
    inherit (lib) concatMapStringsSep mkIf mkOption types;
    cfg = config.internal.services.szuru;
    host = config.networking.hostName;

    szuruSecretPath = "services/szurubooru";
    dataDir = "/var/lib/szurubooru";
    user = "szurubooru";
    group = "szurubooru";

    secret = {
      inherit group;
      mode = "0440";
      owner = user;
    };
  in {
    imports = with self.modules.nixos; [
      postgresql
      secrets
    ];

    options.internal.services.szuru = {
      allowedIPs = mkOption {
        default = null;
        description = "If set, only these source IPs/subnets get firewall rules; otherwise the port is open to all.";
        type = types.nullOr (types.listOf types.str);
      };

      port = mkOption {
        default = 9000;
        description = "Port the web interface listens on.";
        type = types.port;
      };
    };

    config = {
      documentation.nixos.enable = true;

      internal = {
        boot.impermanence.extraDirectories = [dataDir];

        services.postgresql = {
          databases = [
            {
              name = "szurubooru";
              owner = user;

              users = [
                {
                  extraSettings.ensureDBOwnership = true;
                  name = user;
                  passwordFile = config.sops.secrets."${szuruSecretPath}/database_password".path;
                }
              ];
            }
          ];

          user.extraGroups = [group];
        };
      };

      networking.firewall = {
        allowedTCPPorts = mkIf (cfg.allowedIPs == null) [cfg.port];

        extraCommands = mkIf (cfg.allowedIPs != null) ''
          ${concatMapStringsSep "\n" (ip: ''
              iptables -A nixos-fw -p tcp --dport ${toString cfg.port} -s ${ip} -j nixos-fw-accept
            '')
            cfg.allowedIPs}
        '';
      };

      services = {
        nginx = {
          enable = true;

          virtualHosts."${host}.local" = {
            listen = [
              {
                inherit (cfg) port;
                addr = "0.0.0.0";
              }
            ];

            locations = {
              "/" = {
                root = "${pkgs.szurubooru.client}";
                tryFiles = "$uri /index.htm";
              };

              "/data/".alias = "${dataDir}/data/";
              "~ ^/api$".return = "302 /api/";

              "~ ^/api/(.*)$".extraConfig = ''
                if ($request_uri ~* "/api/(.*)") {
                  proxy_pass http://127.0.0.1:8080/$1;
                }
              '';
            };
          };
        };

        szurubooru = {
          inherit dataDir group user;
          enable = true;
          client.package = pkgs.szurubooru.client;
          database.passwordFile = config.sops.secrets."${szuruSecretPath}/database_password".path;

          server = {
            package = pkgs.szurubooru.server;

            settings = {
              delete_source_files = "yes";
              domain = "http://${host}.local:${toString cfg.port}";
              secretFile = config.sops.secrets."${szuruSecretPath}/secret".path;
            };
          };
        };
      };

      sops.secrets = {
        "${szuruSecretPath}/database_password" = secret;
        "${szuruSecretPath}/secret" = secret;
      };
    };
  };
}
