{self, ...}: {
  flake.modules.nixos.caddy = {
    key = "caddy";

    imports = [self.modules.nixos.impermanence-options];

    internal.boot.impermanence = {
      extraDirectories = ["/var/lib/caddy"];
    };

    services = {
      caddy.enable = true;
    };

    networking = {
      firewall = {
        allowedTCPPorts = [80 443];
      };
    };
  };
}
