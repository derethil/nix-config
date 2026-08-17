{
  self,
  lib,
  ...
}: {
  flake.modules.nixos.oauth2-proxy = {config, ...}: let
    inherit (config.internal.homelab) address domain oidc;

    anyProtected = self.lib.homelab.anyProtected config;

    port = "4180";
    subdomain = "oauth";
    host = "${subdomain}.${domain}";
    url = "https://${host}";

    signInUrl = "${url}/oauth2/start";
    signOutUrl = "${url}/oauth2/sign_out";
  in {
    key = "oauth2-proxy";

    imports = [
      self.modules.nixos.ingress
      self.modules.nixos.oidc-options
      self.modules.nixos.secrets
    ];

    config = lib.mkIf anyProtected {
      internal.homelab.authMiddleware = {
        inherit signInUrl signOutUrl;
        copyHeaders = ["X-Auth-Request-User" "X-Auth-Request-Email"];
        endpoint = "127.0.0.1:${port}";
        uri = "/oauth2/auth";
      };

      services = {
        blocky.settings.customDNS.mapping.${host} = address;

        caddy.virtualHosts.${host}.extraConfig = ''
          handle /logout {
            redir * ${signOutUrl}?rd=${oidc.endSessionUrl}
          }

          reverse_proxy 127.0.0.1:${port} {
            header_up X-Real-IP {remote_host}
          }
        '';

        oauth2-proxy = {
          enable = true;
          cookie.domain = ".${domain}";
          email.domains = ["*"];

          extraConfig = {
            skip-provider-button = true;
            whitelist-domain = ".${domain}";
          };

          httpAddress = "http://127.0.0.1:${port}";
          keyFile = config.sops.templates."oauth2-proxy-env".path;
          oidcIssuerUrl = oidc.issuerUrl;
          provider = "oidc";
          redirectURL = "${url}/oauth2/callback";
          reverseProxy = true;
          setXauthrequest = true;
          trustedProxyIP = ["127.0.0.1"];
          upstream = "static://202";
        };
      };

      sops = {
        secrets = {
          "services/oauth2_proxy/cookie_secret" = {};
          "services/oauth2_proxy/oidc/client_id" = {};
          "services/oauth2_proxy/oidc/client_secret" = {};
        };

        templates."oauth2-proxy-env" = {
          mode = "0400";
          content = ''
            OAUTH2_PROXY_CLIENT_ID=${config.sops.placeholder."services/oauth2_proxy/oidc/client_id"}
            OAUTH2_PROXY_CLIENT_SECRET=${config.sops.placeholder."services/oauth2_proxy/oidc/client_secret"}
            OAUTH2_PROXY_COOKIE_SECRET=${config.sops.placeholder."services/oauth2_proxy/cookie_secret"}
          '';
        };
      };

      systemd.services.oauth2-proxy = {
        serviceConfig.RestartSec = "5s";
        startLimitBurst = 20;
        startLimitIntervalSec = 300;
      };
    };
  };
}
