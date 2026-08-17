{self, ...}: {
  flake.modules.nixos.caddy = {
    config,
    pkgs,
    ...
  }: {
    key = "caddy";

    imports = [
      self.modules.nixos.homelab-options
      self.modules.nixos.impermanence-options
      self.modules.nixos.secrets
    ];

    internal.boot.impermanence.extraDirectories = [
      "/var/lib/caddy"
    ];

    networking.firewall.allowedTCPPorts = [443 80];

    services.caddy = {
      enable = true;

      package = pkgs.caddy.withPlugins {
        hash = "sha256-0ZE38PFwQ0OC1N9KhFLM8Fsea6LV4UGUwyZYe3Rg6YQ=";

        plugins = [
          "github.com/caddy-dns/cloudflare@v0.2.4"
          "github.com/ggicci/caddy-jwt@v1.3.0"
        ];
      };

      environmentFile = config.sops.templates."caddy-cloudflare-env".path;

      globalConfig = ''
        email {env.CADDY_ACME_EMAIL}
        acme_dns cloudflare {env.CLOUDFLARE_API_TOKEN}
      '';

      virtualHosts."${config.internal.homelab.domain}".extraConfig = ''
        respond 200
      '';
    };

    sops = {
      secrets = {
        "services/caddy/acme_email" = {};
        "services/caddy/cloudflare_api_token" = {};
      };

      templates."caddy-cloudflare-env".content = ''
        CLOUDFLARE_API_TOKEN=${config.sops.placeholder."services/caddy/cloudflare_api_token"}
        CADDY_ACME_EMAIL=${config.sops.placeholder."services/caddy/acme_email"}
      '';
    };
  };
}
