{
  self,
  lib,
  ...
}: {
  flake = {
    modules.nixos.ingress = {config, ...}: let
      inherit (lib) attrValues concatMapStringsSep count filter mkMerge optionalString unique;

      cfg = config.internal.homelab;
      fqdn = service: "${service.subdomain}.${cfg.domain}";

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
          host = fqdn service;
        in {
          blocky.settings = {
            customDNS.mapping.${host} = cfg.address;
          };

          caddy.virtualHosts.${host}.extraConfig = ''
            ${optionalString service.caddy.protect ''
              forward_auth 127.0.0.1:${toString cfg.ingress.oauth2-proxy.port} {
                uri /oauth2/auth
                header_up X-Real-IP {remote_host}
                copy_headers X-Auth-Request-User X-Auth-Request-Email

                @unauthenticated status 401
                handle_response @unauthenticated {
                  redir * ${self.lib.homelab.mkServiceDomain config "oauth2-proxy"}/oauth2/start?rd={scheme}://{host}{uri}
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
        ];
      };
    };

    lib.homelab = {
      logoutRedirectUrl = config: "${self.lib.homelab.mkServiceDomain config "pocket-id"}/api/oidc/end-session";
      mkServiceDomain = config: service: "https://${config.internal.homelab.ingress."${service}".subdomain}.${config.internal.homelab.domain}";
    };
  };
}
