{self, ...}: {
  flake.modules.nixos.docker = {
    config,
    pkgs,
    ...
  }: {
    environment.systemPackages = [pkgs.lazydocker];

    internal.boot.impermanence.extraDirectories = [
      "/var/lib/docker"
    ];

    users.users = self.lib.forEachNormalUser config (_: {
      extraGroups = ["docker"];
    });

    virtualisation.docker = {
      enable = true;
      autoPrune.enable = true;
      enableOnBoot = true;
    };
  };
}
