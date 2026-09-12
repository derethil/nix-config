{
  flake.modules.nixos.tailscale = {config, ...}: {
    internal.boot.impermanence.extraDirectories = [
      "/var/lib/tailscale"
    ];

    networking.firewall = {
      allowedUDPPorts = [config.services.tailscale.port];
      trustedInterfaces = ["tailscale0"];
    };

    services.tailscale.enable = true;
  };
}
