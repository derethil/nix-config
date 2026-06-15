{self, ...}: {
  flake.modules.nixos.sober = {
    imports = [self.modules.nixos.flatpak];

    services.flatpak.packages = [
      {
        appId = "org.vinegarhq.Sober";
        origin = "flathub";
      }
    ];
  };
}
