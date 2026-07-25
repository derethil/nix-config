{self, ...}: {
  flake.modules.homeManager.browsers = {
    imports = [
      self.modules.homeManager.chromium
      self.modules.homeManager.firefox
    ];
  };
}
