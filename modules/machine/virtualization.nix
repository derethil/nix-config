{self, ...}: let
  inherit (self.lib) forEachNormalUser;
in {
  flake.modules.nixos.virtualization = {config, ...}: {
    programs.virt-manager.enable = true;

    users.users = forEachNormalUser config (_: {
      extraGroups = ["libvirt"];
    });

    virtualisation.libvirtd.enable = true;
  };
}
