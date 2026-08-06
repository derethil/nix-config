{self, ...}: {
  flake.modules.nixos.homelab = {
    imports = [
      self.modules.nixos.blombooru
      self.modules.nixos.healthchecks
      self.modules.nixos.ntfy
      self.modules.nixos.paperless-ngx
      self.modules.nixos.tandoor-recipes
    ];
  };
}
