{
  lib,
  config,
  pkgs,
  inputs,
  ...
}: let
  inherit (lib) mkIf types concatMapStringsSep;
  inherit (lib.glace) mkBoolOpt mkOpt mkNullableOpt;
  cfg = config.glace.services.szuru;
in {
  imports = [
    "${inputs.nixpkgs-unstable}/nixos/modules/services/web-apps/szurubooru.nix"
  ];

  options.glace.services.szuru = with types; {
    enable = mkBoolOpt false "Enable Szurubooru";
    port = mkOpt port 9000 "Port for the web interface";
    allowedIPs = mkNullableOpt (listOf str) null "List of IP addresses/subnets allowed to access szurubooru";
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
      # NOTE: Disable NixOS manual generation to prevent build conflicts with unstable szurubooru module docs.
      # Re-enable when upgrading to nixpkgs 26+
      documentation.nixos.enable = false;

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
        server = {
          package = pkgs.unstable.szurubooru.server;
          settings = {
            domain = "http://athena.local:${toString cfg.port}";
            delete_source_files = "yes";
            secretFile = config.sops.secrets."${szuruSecretPath}/secret".path;
          };
        };
        database = {
          passwordFile = config.sops.secrets."${szuruSecretPath}/database_password".path;
        };
        client = {
          package = pkgs.unstable.szurubooru.client;
        };
      };

      services.nginx = {
        enable = true;
        virtualHosts."athena.local" = {
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
              root = "${pkgs.unstable.szurubooru.client}";
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

      glace.system.impermanence.extraDirectories = [dataDir];
    };
}
