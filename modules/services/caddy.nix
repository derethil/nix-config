{self, ...}: {
  flake.modules.nixos.caddy = {
    config,
    pkgs,
    ...
  }: {
    key = "caddy";

    imports = [
      self.modules.nixos.impermanence-options
      self.modules.nixos.secrets
    ];

    internal.boot.impermanence.extraDirectories = [
      "/var/lib/caddy"
    ];

    sops = {
      secrets."services/homelab/caddy/cloudflare_api_token" = {};
      secrets."services/homelab/caddy/acme_email" = {};
      templates."caddy-cloudflare-env".content = ''
        CLOUDFLARE_API_TOKEN=${config.sops.placeholder."services/homelab/caddy/cloudflare_api_token"}
        CADDY_ACME_EMAIL=${config.sops.placeholder."services/homelab/caddy/acme_email"}
      '';
    };

    services.caddy = {
      enable = true;

      package = pkgs.caddy.withPlugins {
        plugins = ["github.com/caddy-dns/cloudflare@v0.2.4"];
        hash = "sha256-7GoH8YLCoPmPExQxoga2FHB58zQDoZVf1BBwkVi0SsQ=";
      };

      globalConfig = ''
        email {env.CADDY_ACME_EMAIL}
        acme_dns cloudflare {env.CLOUDFLARE_API_TOKEN}
      '';

      environmentFile = config.sops.templates."caddy-cloudflare-env".path;
    };

    networking.firewall.allowedTCPPorts = [80 443];
  };
}
