{self, ...}: {
  flake.modules = {
    nixos.removable-media = {
      home-manager.sharedModules = [
        self.modules.homeManager.removable-media
      ];
    };

    homeManager.removable-media.services.udiskie = {
      enable = true;
      automount = true;
      notify = true;
      tray = "auto";
    };

    services.udisks2.enable = true;
  };
}
