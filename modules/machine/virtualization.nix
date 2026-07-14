{self, ...}: let
  inherit (self.lib) forEachNormalUser;
in {
  flake.modules.nixos.virtualization = {config, ...}: {
    virtualisation.libvirtd = {
      enable = true;
    };

    programs.virt-manager = {
      enable = true;
    };

    users.users = forEachNormalUser config (_: {
      extraGroups = ["libvirt"];
    });
  };
}
