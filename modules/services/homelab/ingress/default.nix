{
  self,
  lib,
  ...
}: {
  flake = {
    modules.nixos.ingress = {config, ...}: let
      inherit (lib) attrValues concatMapStringsSep concatStringsSep count filter mkMerge optionalString unique;

      cfg = config.internal.homelab;

      anyProtected = self.lib.homelab.anyProtected config;
      auth = cfg.authMiddleware;

      usedPorts = map (service: service.port) (attrValues cfg.ingress);
      duplicatePorts = unique (filter (port: count (other: other == port) usedPorts > 1) usedPorts);

      usedSubdomains = map (service: service.subdomain) (attrValues cfg.ingress);
      duplicateSubdomains = unique (filter (subdomain: count (other: other == subdomain) usedSubdomains > 1) usedSubdomains);
    in {
      key = "ingress";

      imports = [
        self.modules.nixos.blocky
        self.modules.nixos.caddy
        self.modules.nixos.ingress-options
      ];

      config = let
        publishService = service: let
          host = service.fqdn;
        in {
          blocky.settings = {
            customDNS.mapping.${host} = cfg.address;
          };

          caddy.virtualHosts.${host}.extraConfig = ''
            ${optionalString (service.caddy.proxyProtect && auth != null) ''
              forward_auth ${auth.endpoint} {
                uri ${auth.uri}
                header_up X-Real-IP {remote_host}
                ${optionalString (auth.copyHeaders != []) "copy_headers ${concatStringsSep " " auth.copyHeaders}"}

                @unauthenticated status 401
                handle_response @unauthenticated {
                  redir * ${auth.signInUrl}?rd={scheme}://{host}{uri}
                }
              }
            ''}

            reverse_proxy 127.0.0.1:${toString service.port} {
              header_up X-Real-IP {remote_host}
            }

            ${service.caddy.extraConfig}
          '';
        };
      in {
        services = mkMerge (map publishService (attrValues cfg.ingress));

        assertions = [
          {
            assertion = duplicatePorts == [];
            message = "internal.homelab.ingress: ports must be unique across services; reused: ${concatMapStringsSep ", " toString duplicatePorts}";
          }
          {
            assertion = duplicateSubdomains == [];
            message = "internal.homelab.ingress: subdomains must be unique across services; reused: ${concatMapStringsSep ", " toString duplicateSubdomains}";
          }
          {
            assertion = anyProtected -> (auth != null);
            message = "internal.homelab.ingress: a service sets caddy.proxyProtect but no authMiddleware is configured; import an auth provider (e.g. self.modules.nixos.oauth2-proxy).";
          }
        ];
      };
    };

    lib.homelab.anyProtected = config: lib.any (service: service.caddy.proxyProtect) (lib.attrValues config.internal.homelab.ingress);
  };
}
