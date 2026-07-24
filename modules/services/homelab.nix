{
  lib,
  self,
  ...
}: {
  flake.modules.nixos.homelab = {config, ...}: let
    inherit (lib) mkOption types toInt mkMerge attrValues concatMapStringsSep count filter unique;

    cfg = config.internal.homelab;
    fqdn = service: "${service.subdomain}.${cfg.domain}";

    usedPorts = map (service: service.port) (attrValues cfg.services);
    duplicates = unique (filter (port: count (other: other == port) usedPorts > 1) usedPorts);
  in {
    key = "homelab";

    imports = [
      self.modules.nixos.blocky
      self.modules.nixos.caddy
    ];

    options.internal.homelab.services = mkOption {
      default = {};
      description = "Homelab services to publish: each gets a DNS record and a reverse proxy.";
      type = types.attrsOf (types.submodule ({name, ...}: {
        options = {
          subdomain = mkOption {
            type = types.str;
            default = name;
            description = "Subdomain under internal.homelab.domain (defaults to the attribute name).";
          };
          port = mkOption {
            type = types.coercedTo types.str toInt types.port;
            description = "Loopback port the reverse proxy forwards to (declared as a string, validated as a port).";
          };
          extraConfig = mkOption {
            type = types.lines;
            default = "";
            description = "Extra Caddyfile directives appended inside the generated vhost (e.g. basic_auth, forward_auth, headers).";
          };
        };
      }));
    };

    config = let
      publishService = service: let
        host = fqdn service;
      in {
        caddy.virtualHosts.${host}.extraConfig = ''
          reverse_proxy 127.0.0.1:${toString service.port}
          ${service.extraConfig}
        '';

        blocky = {
          settings = {
            customDNS.mapping.${host} = cfg.address;
          };
        };
      };
    in {
      services = mkMerge (map publishService (attrValues cfg.services));

      assertions = [
        {
          assertion = duplicates == [];
          message = "internal.homelab.services: ports must be unique across services; reused: ${concatMapStringsSep ", " toString duplicates}";
        }
      ];
    };
  };
}
