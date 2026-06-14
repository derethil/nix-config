{self, ...}: {
  flake.modules.homeManager.browsers = {
    imports = [
      self.modules.homeManager.firefox
      self.modules.homeManager.chromium
    ];
  };
}
