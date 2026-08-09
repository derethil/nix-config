{self, ...}: {
  flake.modules.nixos.oauth2-proxy = {config, ...}: let
    cfg = config.internal.homelab.ingress.oauth2-proxy;
    domain = config.internal.homelab.domain;

    port = "4180";
    subdomain = "oauth";
  in {
    imports = [
      self.modules.nixos.ingress
      self.modules.nixos.secrets
    ];

    internal.homelab.ingress.oauth2-proxy = {
      inherit port subdomain;

      caddy.extraConfig = ''
        handle /logout {
          redir * /oauth2/sign_out?rd=${self.lib.homelab.logoutRedirectUrl config}
        }
      '';
    };

    services.oauth2-proxy = {
      enable = true;
      cookie.domain = ".${domain}";
      email.domains = ["*"];

      extraConfig = {
        skip-provider-button = true;
        whitelist-domain = ".${domain}";
      };

      httpAddress = "http://127.0.0.1:${toString cfg.port}";
      keyFile = config.sops.templates."oauth2-proxy-env".path;
      oidcIssuerUrl = self.lib.homelab.mkServiceDomain config "pocket-id";
      provider = "oidc";
      redirectURL = "https://${subdomain}.${domain}/oauth2/callback";
      reverseProxy = true;
      setXauthrequest = true;
      trustedProxyIP = ["127.0.0.1"];
      upstream = "static://202";
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
  };
}
