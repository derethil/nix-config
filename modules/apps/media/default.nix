{self, ...}: {
  flake.modules.homeManager.media = {
    imports = [
      self.modules.homeManager.spotify
      self.modules.homeManager.stremio
      self.modules.homeManager.vlc
    ];
  };
}
