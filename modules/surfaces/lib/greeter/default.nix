{self, ...}: {
  flake.modules.nixos.greeter = {
    imports = [self.modules.nixos.noctalia-greeter];
    services.displayManager.enable = true;
  };
}
