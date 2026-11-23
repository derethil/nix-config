{self, ...}: let
  inherit (self.lib.podman) user;
in {
  flake.modules = {
    nixos.arr-network.config.home-manager.users.${user}.imports = [self.modules.homeManager.arr-network];
    homeManager.arr-network.virtualisation.quadlet.networks.arr = {};
  };
}
