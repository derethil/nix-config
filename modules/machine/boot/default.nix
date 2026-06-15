{self, ...}: {
  flake.modules.nixos.boot = {...}: {
    imports = with self.modules.nixos; [
      kernel
      loader
    ];
  };
}
