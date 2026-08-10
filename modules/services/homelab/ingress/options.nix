{
  self,
  lib,
  ...
}: let
  inherit (lib) mkOption toInt types;
in {
  flake.modules.nixos.ingress-options = {config, ...}: let
    inherit (config.internal.homelab) domain;
  in {
    key = "ingress-options";
    imports = [self.modules.nixos.homelab-options];

    options.internal.homelab = {
      authMiddleware = mkOption {
        default = null;
        description = "Forward-auth middleware that proxyProtect services are gated behind. Populated by an auth provider module (e.g. oauth2-proxy); null when no provider is present.";

        type = types.nullOr (types.submodule {
          options = {
            copyHeaders = mkOption {
              default = [];
              description = "Response headers copied from the auth subrequest onto the upstream request on success.";
              type = types.listOf types.str;
            };

            endpoint = mkOption {
              description = "host:port Caddy sends the forward_auth subrequest to.";
              type = types.str;
            };

            signInUrl = mkOption {
              description = "URL unauthenticated requests are redirected to; the original request is appended as an rd query parameter.";
              type = types.str;
            };

            signOutUrl = mkOption {
              description = "URL that clears the middleware session; an rd query parameter may be appended to redirect afterwards.";
              type = types.str;
            };

            uri = mkOption {
              description = "Request URI Caddy queries on the endpoint to verify the session.";
              type = types.str;
            };
          };
        });
      };

      ingress = mkOption {
        default = {};
        description = "Homelab services to route: each gets a DNS record and a reverse proxy.";

        type = types.attrsOf (types.submodule ({
          config,
          name,
          ...
        }: {
          options = {
            caddy = {
              extraConfig = mkOption {
                default = "";
                description = "Extra Caddyfile directives appended inside the generated vhost (e.g. basic_auth, forward_auth, headers).";
                type = types.lines;
              };

              proxyProtect = mkOption {
                default = false;
                description = "Gate this service behind the configured authMiddleware via forward_auth.";
                type = types.bool;
              };
            };

            fqdn = mkOption {
              default = "${config.subdomain}.${domain}";
              description = "Fully-qualified hostname (subdomain.domain). Derived; do not set.";
              readOnly = true;
              type = types.str;
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

            url = mkOption {
              default = "https://${config.fqdn}";
              description = "Public https URL for the service. Derived; do not set.";
              readOnly = true;
              type = types.str;
            };
          };
        }));
      };
    };
  };
}
