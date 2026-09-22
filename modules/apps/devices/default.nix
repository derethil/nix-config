{self, ...}: {
  flake.modules.nixos.devices.imports = [
    self.modules.nixos.librepods
    self.modules.nixos.sideloading
    self.modules.nixos.tether
  ];
}
