{self, ...}: {
  # Base gaming modules

  flake.modules.nixos.lightweight-gaming = {
    imports = [
      self.modules.nixos.steam
      self.modules.nixos.wine
      self.modules.nixos.mangohud
      self.modules.nixos.ntsync
      self.modules.nixos.sober
    ];
  };

  flake.modules.darwin.lightweight-gaming = {
    imports = [
      self.modules.darwin.steam
    ];
  };

  flake.modules.homeManager.lightweight-gaming = {
    imports = [
      self.modules.homeManager.wine
      self.modules.homeManager.protonup-qt
      self.modules.homeManager.prismlauncher
      self.modules.homeManager.mangohud
    ];
  };

  # Use on high-end hardware

  flake.modules.nixos.gaming = {
    imports = [
      self.modules.nixos.lightweight-gaming
      self.modules.nixos.starcitizen
    ];
  };

  flake.modules.darwin.gaming = {
    imports = [
      self.modules.darwin.lightweight-gaming
    ];
  };

  flake.modules.homeManager.gaming = {
    imports = [
      self.modules.homeManager.lightweight-gaming
      self.modules.homeManager.lossless-scaling
    ];
  };
}
