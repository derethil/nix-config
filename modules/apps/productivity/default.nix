{self, ...}: {
  flake.modules = {
    nixos.productivity.imports = [
      self.modules.nixos.rbw
    ];

    homeManager.productivity.imports = [
      self.modules.homeManager.obsidian
      self.modules.homeManager.qalculate
    ];
  };
}
