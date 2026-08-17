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
      anyJwtBearer = self.lib.homelab.anyJwtBearer config;
      auth = cfg.authMiddleware;

      usedPorts = map (service: service.port) (attrValues cfg.ingress);
      duplicatePorts = unique (filter (port: count (other: other == port) usedPorts > 1) usedPorts);

      usedSubdomains = map (service: service.subdomain) (attrValues cfg.ingress);
      duplicateSubdomains = unique (filter (subdomain: count (other: other == subdomain) usedSubdomains > 1) usedSubdomains);

      jwtBearerServices = filter (service: service.caddy.jwtBearer.enable) (attrValues cfg.ingress);
      jwtBearerWithoutForwardAuth = filter (service: !service.caddy.forwardAuth.enable) jwtBearerServices;
      jwtBearerMissingAudience = filter (service: service.caddy.jwtBearer.audience == null) jwtBearerServices;
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
          jwtBearer = service.caddy.jwtBearer;
          forwardAuth = service.caddy.forwardAuth;

          defaultProxy = ''
            reverse_proxy 127.0.0.1:${toString service.port} {
              header_up X-Real-IP {remote_host}
            }
          '';

          jwtBearerBlock = optionalString jwtBearer.enable ''
            @jwtBearer header ${jwtBearer.header} *
            route @jwtBearer {
              jwtauth {
                jwk_url ${cfg.oidc.issuerUrl}/.well-known/jwks.json
                issuer_whitelist ${cfg.oidc.issuerUrl}
                audience_whitelist ${jwtBearer.audience}
                from_header ${jwtBearer.header}
              }

              ${defaultProxy}
            }
          '';

          forwardAuthBlock = optionalString (forwardAuth.enable && auth != null) ''
            forward_auth ${auth.endpoint} {
              uri ${auth.uri}
              header_up X-Real-IP {remote_host}
              ${optionalString (auth.copyHeaders != []) "copy_headers ${concatStringsSep " " auth.copyHeaders}"}

              @unauthenticated status 401
              handle_response @unauthenticated {
                redir * ${auth.signInUrl}?rd={scheme}://{host}{uri}
              }
            }
          '';
        in {
          blocky.settings = {
            customDNS.mapping.${host} = cfg.address;
          };

          # Wrap in route to preserve order of the blocks
          caddy.virtualHosts.${host}.extraConfig = ''
            route {
              ${concatStringsSep "\n" (
              filter (block: block != "") [
                jwtBearerBlock
                forwardAuthBlock
                defaultProxy
              ]
            )}
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
            message = "internal.homelab.ingress: a service sets caddy.forwardAuth.enable but no authMiddleware is configured; import an auth provider (e.g. self.modules.nixos.oauth2-proxy).";
          }
          {
            assertion = anyJwtBearer -> (cfg.oidc != null);
            message = "internal.homelab.ingress: a service sets caddy.jwtBearer.enable but no OIDC provider is configured; import an identity provider (e.g. self.modules.nixos.pocket-id).";
          }
          {
            assertion = jwtBearerWithoutForwardAuth == [];
            message = "internal.homelab.ingress: caddy.jwtBearer.enable requires caddy.forwardAuth.enable to also be set, otherwise requests without a bearer token bypass authentication entirely; affected: ${concatMapStringsSep ", " (service: service.subdomain) jwtBearerWithoutForwardAuth}";
          }
          {
            assertion = jwtBearerMissingAudience == [];
            message = "internal.homelab.ingress: caddy.jwtBearer.enable requires caddy.jwtBearer.audience to be set; affected: ${concatMapStringsSep ", " (service: service.subdomain) jwtBearerMissingAudience}";
          }
        ];
      };
    };

    lib.homelab = {
      anyJwtBearer = config: lib.any (service: service.caddy.jwtBearer.enable) (lib.attrValues config.internal.homelab.ingress);
      anyProtected = config: lib.any (service: service.caddy.forwardAuth.enable) (lib.attrValues config.internal.homelab.ingress);
    };
  };
}
