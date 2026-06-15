{self, ...}: {
  flake.modules.homeManager.utilities = {
    imports = [
      self.modules.homeManager.obsidian
      self.modules.homeManager.qalculate
      self.modules.homeManager.pinta
    ];
  };

  flake.modules.nixos.utilities = {
    imports = [
      self.modules.nixos.sideloading
    ];
  };
}
