{self, ...}: {
  flake.modules.homeManager.comms = {
    imports = [
      self.modules.homeManager.discord
    ];
  };

  flake.modules.homeManager.comms-work = {
    imports = [
      self.modules.homeManager.comms
      self.modules.homeManager.mattermost
      self.modules.homeManager.zoom
    ];
  };

  flake.modules.darwin.comms-work = {
    imports = [
      self.modules.darwin.discord
      self.modules.darwin.mattermost
    ];
  };
}
