{self, ...}: {
  flake.modules = {
    darwin.comms-work.imports = [
      self.modules.darwin.discord
      self.modules.darwin.mattermost
    ];

    homeManager = {
      comms.imports = [
        self.modules.homeManager.discord
      ];

      comms-work.imports = [
        self.modules.homeManager.comms
        self.modules.homeManager.mattermost
      ];
    };
  };
}
