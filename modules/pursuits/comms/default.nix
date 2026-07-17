{self, ...}: {
  flake.modules = {
    homeManager.comms = {
      imports = [
        self.modules.homeManager.discord
      ];
    };

    homeManager.comms-work = {
      imports = [
        self.modules.homeManager.comms
        self.modules.homeManager.mattermost
      ];
    };

    darwin.comms-work = {
      imports = [
        self.modules.darwin.discord
        self.modules.darwin.mattermost
      ];
    };
  };
}
