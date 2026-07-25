{lib, ...}: {
  flake.modules.nixos.blocky = {config, ...}: let
    inherit (lib) mkOption types;
    inherit (config.internal.homelab) address;
  in {
    key = "blocky";

    options.internal.homelab = {
      address = mkOption {
        default = "192.168.8.10";
        description = "LAN IP that homelab DNS records resolve to (feldspar's static address).";
        type = types.str;
      };

      domain = mkOption {
        default = "lumelle.me";
        description = "Base domain homelab services are published under (e.g. recipes.\${domain}).";
        type = types.str;
      };
    };

    config = {
      networking.firewall = {
        allowedTCPPorts = [53];
        allowedUDPPorts = [53];
      };

      services.blocky = {
        enable = true;

        settings = {
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
