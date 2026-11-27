{self, ...}: {
  flake.modules = {
    nixos.productivity.imports = [
      self.modules.nixos.rbw
    ];

    darwin.productivity.imports = [
      self.modules.darwin.mos
      self.modules.darwin.protonvpn
    ];

    homeManager.productivity.imports = [
      self.modules.homeManager.obsidian
      self.modules.homeManager.protonvpn
      self.modules.homeManager.qalculate
    ];
  };
}
