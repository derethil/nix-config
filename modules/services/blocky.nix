{lib, ...}: {
  flake.modules.nixos.blocky = {config, ...}: let
    inherit (lib) mkOption types;
    inherit (config.internal.homelab) address;
  in {
    key = "blocky";

    options.internal.homelab = {
      address = mkOption {
        type = types.str;
        default = "192.168.8.10";
        description = "LAN IP that homelab DNS records resolve to (feldspar's static address).";
      };

      domain = mkOption {
        type = types.str;
        default = "lumelle.me";
        description = "Base domain homelab services are published under (e.g. recipes.\${domain}).";
      };
    };

    config = {
      services.blocky = {
        enable = true;
        settings = {
          # aardvark-dns from podman already on 10.88.0.1:53 so listen only on loopback and the LAN address
          ports.dns = "127.0.0.1:53,${address}:53";

          upstreams.groups.default = [
            "1.1.1.1"
            "1.0.0.1"
          ];

          customDNS = {
            customTTL = "1h";
            filterUnmappedTypes = true;
          };
        };
      };

      systemd.services.blocky = {
        startLimitIntervalSec = 0;
        serviceConfig.RestartSec = "2";
      };

      networking.firewall = {
        allowedTCPPorts = [53];
        allowedUDPPorts = [53];
      };
    };
  };
}
