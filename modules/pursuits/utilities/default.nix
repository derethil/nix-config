{self, ...}: {
  flake.modules = {
    nixos.utilities.imports = [
      self.modules.nixos.sideloading
      self.modules.nixos.rbw
    ];

    homeManager.utilities.imports = [
      self.modules.homeManager.obsidian
      self.modules.homeManager.pinta
      self.modules.homeManager.qalculate
    ];
  };
}
