{
  self,
  lib,
  ...
}: {
  flake = {
    modules.nixos.ingress = {config, ...}: let
      inherit (lib) attrValues concatMapStringsSep count filter mkMerge mkOption toInt types unique;

      cfg = config.internal.homelab;
      fqdn = service: "${service.subdomain}.${cfg.domain}";

      usedPorts = map (service: service.port) (attrValues cfg.ingress);
      duplicates = unique (filter (port: count (other: other == port) usedPorts > 1) usedPorts);
    in {
      key = "ingress";

      imports = [
        self.modules.nixos.blocky
        self.modules.nixos.caddy
      ];

      options.internal.homelab.ingress = mkOption {
        default = {};
        description = "Homelab services to route: each gets a DNS record and a reverse proxy.";

        type = types.attrsOf (types.submodule ({name, ...}: {
          options = {
            caddy.extraConfig = mkOption {
              default = "";
              description = "Extra Caddyfile directives appended inside the generated vhost (e.g. basic_auth, forward_auth, headers).";
              type = types.lines;
            };

            port = mkOption {
              description = "Loopback port the reverse proxy forwards to (declared as a string, validated as a port).";
              type = types.coercedTo types.str toInt types.port;
            };

            subdomain = mkOption {
              default = name;
              description = "Subdomain under internal.homelab.domain (defaults to the attribute name).";
              type = types.str;
            };
          };
        }));
      };

      config = let
        publishService = service: let
          host = fqdn service;
        in {
          blocky.settings = {
            customDNS.mapping.${host} = cfg.address;
          };

          caddy.virtualHosts.${host}.extraConfig = ''
            reverse_proxy 127.0.0.1:${toString service.port}
            ${service.caddy.extraConfig}
          '';
        };
      in {
        services = mkMerge (map publishService (attrValues cfg.ingress));

        assertions = [
          {
            assertion = duplicates == [];
            message = "internal.homelab.ingress: ports must be unique across services; reused: ${concatMapStringsSep ", " toString duplicates}";
          }
        ];
      };
    };

    lib.homelab.mkServiceDomain = config: service: "https://${config.internal.homelab.ingress."${service}".subdomain}.${config.internal.homelab.domain}";
  };
}
