{self, ...}: {
  flake.modules = {
    nixos.shell.imports = [
      self.modules.nixos.fish
      self.modules.nixos.nix-index
      self.modules.nixos.tools
      self.modules.nixos.yazi
    ];

    darwin.shell.imports = [
      self.modules.darwin.fish
      self.modules.darwin.nix-index
      self.modules.darwin.tools
    ];

    homeManager.shell.imports = [
      self.modules.homeManager.atuin
      self.modules.homeManager.fish
      self.modules.homeManager.nix-index
      self.modules.homeManager.starship
      self.modules.homeManager.tmux
      self.modules.homeManager.tools
      self.modules.homeManager.yazi
    ];
  };
}
