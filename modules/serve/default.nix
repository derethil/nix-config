{self, ...}: {
  flake.modules.nixos.homelab = {
    imports = [
      self.modules.nixos.blombooru
      self.modules.nixos.bookorbit
      self.modules.nixos.gatus
      self.modules.nixos.oauth2-proxy
      self.modules.nixos.paperless-ngx
      self.modules.nixos.pocket-id
      self.modules.nixos.prowlarr
      self.modules.nixos.sabnzbd
      self.modules.nixos.tandoor-recipes
    ];
  };
}
