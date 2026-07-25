{self, ...}: {
  flake.modules = {
    nixos = {
      # Use on high-end hardware
      gaming.imports = [
        self.modules.nixos.lightweight-gaming
        self.modules.nixos.starcitizen
      ];

      # Base gaming modules
      lightweight-gaming.imports = [
        self.modules.nixos.mangohud
        self.modules.nixos.ntsync
        self.modules.nixos.sober
        self.modules.nixos.steam
        self.modules.nixos.wine
      ];
    };

    darwin = {
      gaming.imports = [
        self.modules.darwin.lightweight-gaming
      ];

      lightweight-gaming.imports = [
        self.modules.darwin.steam
      ];
    };

    homeManager = {
      gaming.imports = [
        self.modules.homeManager.lightweight-gaming
        self.modules.homeManager.lossless-scaling
      ];

      lightweight-gaming.imports = [
        self.modules.homeManager.mangohud
        self.modules.homeManager.prismlauncher
        self.modules.homeManager.protonup-qt
        self.modules.homeManager.wine
      ];
    };
  };
}
