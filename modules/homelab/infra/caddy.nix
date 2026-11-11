{self, ...}: let
  cloudflarePlugin = {
    datasource = "github-tags";
    packageName = "caddy-dns/cloudflare";
    version = "v0.2.4";
    versioning = "semver-coerced";
  };

  jwtPlugin = {
    datasource = "github-tags";
    packageName = "ggicci/caddy-jwt";
    version = "v1.4.0";
    versioning = "semver-coerced";
  };
in {
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
        # regen-hash: nixosConfigurations.feldspar.config.services.caddy.package.src
        hash = "sha256-bHMI9ueUyZjhSVcn9RzjyeYHtvAFibrrWOOY8xm5Bg4=";

        plugins = [
          "github.com/${cloudflarePlugin.packageName}@${cloudflarePlugin.version}"
          "github.com/${jwtPlugin.packageName}@${jwtPlugin.version}"
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
