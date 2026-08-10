{self, ...}: {
  flake = {
    modules.nixos.podman = {
      config,
      pkgs,
      ...
    }: {
      key = "podman";
      imports = [self.modules.nixos.impermanence-options];

      environment.systemPackages = [
        pkgs.podman
      ];

      internal.boot.impermanence.extraDirectories = ["/var/lib/containers"];

      users.users = self.lib.forEachNormalUser config (_: {
        extraGroups = ["podman"];
      });

      virtualisation = {
        containers.enable = true;

        podman = {
          enable = true;
          defaultNetwork.settings.dns_enabled = true;
        };
      };
    };

    lib.podman = {
      svc = container: "${container}.service";
      volume = name: "/var/lib/containers/storage/volumes/${name}/_data";
    };
  };
}
