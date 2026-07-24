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
    inherit (lib) mkOption types mkIf concatMapStringsSep;
    cfg = config.internal.services.szuru;
    host = config.networking.hostName;

    szuruSecretPath = "services/szurubooru";
    dataDir = "/var/lib/szurubooru";
    user = "szurubooru";
    group = "szurubooru";

    secret = {
      inherit group;
      owner = user;
      mode = "0440";
    };
  in {
    imports = with self.modules.nixos; [
      postgresql
      secrets
    ];

    options.internal.services.szuru = {
      port = mkOption {
        type = types.port;
        default = 9000;
        description = "Port the web interface listens on.";
      };
      allowedIPs = mkOption {
        type = types.nullOr (types.listOf types.str);
        default = null;
        description = "If set, only these source IPs/subnets get firewall rules; otherwise the port is open to all.";
      };
    };

    config = {
      documentation.nixos.enable = true;

      internal.services.postgresql = {
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

      sops.secrets = {
        "${szuruSecretPath}/secret" = secret;
        "${szuruSecretPath}/database_password" = secret;
      };

      services.szurubooru = {
        enable = true;
        inherit user group dataDir;
        server = {
          package = pkgs.szurubooru.server;
          settings = {
            domain = "http://${host}.local:${toString cfg.port}";
            delete_source_files = "yes";
            secretFile = config.sops.secrets."${szuruSecretPath}/secret".path;
          };
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
        virtualHosts."${host}.local" = {
          listen = [
            {
              addr = "0.0.0.0";
              inherit (cfg) port;
            }
          ];
          locations = {
            "~ ^/api$".return = "302 /api/";
            "~ ^/api/(.*)$".extraConfig = ''
              if ($request_uri ~* "/api/(.*)") {
                proxy_pass http://127.0.0.1:8080/$1;
              }
            '';
            "/data/".alias = "${dataDir}/data/";
            "/" = {
              tryFiles = "$uri /index.htm";
              root = "${pkgs.szurubooru.client}";
            };
          };
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

      internal.boot.impermanence.extraDirectories = [dataDir];
    };
  };
}
