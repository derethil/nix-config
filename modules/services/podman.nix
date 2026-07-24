{self, ...}: {
  flake.modules.nixos.podman = {
    config,
    pkgs,
    ...
  }: {
    key = "podman";

    imports = [self.modules.nixos.impermanence-options];

    internal.boot.impermanence = {
      extraDirectories = ["/var/lib/containers"];
    };

    virtualisation = {
      containers = {
        enable = true;
      };

      podman = {
        enable = true;
        defaultNetwork = {
          settings.dns_enabled = true;
        };
      };
    };

    users.users = self.lib.forEachNormalUser config (_: {
      extraGroups = ["podman"];
    });

    environment.systemPackages = [
      pkgs.podman
    ];
  };
}
