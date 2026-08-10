{
  self,
  lib,
  ...
}: {
  flake.modules.nixos.blocky = {config, ...}: let
    inherit (lib) attrNames head mkIf;
    inherit (config.internal.homelab) address;

    mappedHosts = attrNames (config.services.blocky.settings.customDNS.mapping or {});
  in {
    key = "blocky";

    imports = [
      self.modules.nixos.gatus-options
      self.modules.nixos.homelab-options
    ];

    config = {
      internal.homelab.gatus.endpoints = mkIf (mappedHosts != []) {
        blocky = {
          conditions = [
            "[DNS_RCODE] == NOERROR"
            "[BODY] == ${address}"
          ];

          dns = {
            query-name = "${head mappedHosts}.";
            query-type = "A";
          };

          group = "internal";
          url = address;
        };
      };

      networking.firewall = {
        allowedTCPPorts = [53];
        allowedUDPPorts = [53];
      };

      services.blocky = {
        enable = true;

        settings = {
          # Do not map the apex (config.internal.homelab.domain) here. It must stay
          # unmapped so blocky forwards its SOA to Cloudflare; otherwise
          # filterUnmappedTypes returns NODATA and Caddy's DNS-01 zone walk slides
          # up to the ".me" TLD and cert issuance fails. If we ever need per-host
          # tls config in Caddy, switch to a `resolvers 1.1.1.1 1.0.0.1` tls block
          # per the Caddy cloudflare plugin README instead and this constraint goes away.
          customDNS = {
            customTTL = "1h";
            filterUnmappedTypes = true;
          };

          # aardvark-dns from podman already on 10.88.0.1:53 so listen only on loopback and the LAN address
          ports.dns = "127.0.0.1:53,${address}:53";

          upstreams.groups.default = [
            "1.0.0.1"
            "1.1.1.1"
          ];
        };
      };

      systemd.services.blocky = {
        serviceConfig.RestartSec = "2";
        startLimitIntervalSec = 0;
      };
    };
  };
}
