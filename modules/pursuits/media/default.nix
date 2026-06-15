{self, ...}: {
  flake.modules.homeManager.media = {
    imports = [
      self.modules.homeManager.stremio
      self.modules.homeManager.vlc
      self.modules.homeManager.spotify
    ];
  };
}
