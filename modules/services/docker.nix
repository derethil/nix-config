{self, ...}: {
  flake.modules.nixos.docker = {
    config,
    pkgs,
    ...
  }: {
    virtualisation.docker = {
      enable = true;
      enableOnBoot = true;
      autoPrune.enable = true;
    };

    environment.systemPackages = [pkgs.lazydocker];

    users.users = self.lib.forEachNormalUser config (_: {
      extraGroups = ["docker"];
    });

    internal.boot.impermanence.extraDirectories = [
      "/var/lib/docker"
    ];
  };
}
