{lib, ...}: let
  inherit (lib) mkOption toInt types;
in {
  flake.modules.nixos.ingress-options = {
    key = "ingress-options";

    options.internal.homelab.ingress = mkOption {
      default = {};
      description = "Homelab services to route: each gets a DNS record and a reverse proxy.";

      type = types.attrsOf (types.submodule ({name, ...}: {
        options = {
          caddy = {
            extraConfig = mkOption {
              default = "";
              description = "Extra Caddyfile directives appended inside the generated vhost (e.g. basic_auth, forward_auth, headers).";
              type = types.lines;
            };

            protect = mkOption {
              default = false;
              description = "Gate this service behind proxy OIDC authentication via forward_auth.";
              type = types.bool;
            };
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
  };
}
