{self, ...}: {
  flake.modules.nixos.homelab = {
    imports = [
      self.modules.nixos.blombooru
      self.modules.nixos.gatus
      self.modules.nixos.paperless-ngx
      self.modules.nixos.pocket-id
      self.modules.nixos.tandoor-recipes
    ];
  };
}
