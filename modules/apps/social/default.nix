{self, ...}: {
  flake.modules = {
    darwin.social-work.imports = [
      self.modules.darwin.discord
      self.modules.darwin.mattermost
    ];

    homeManager = {
      social.imports = [
        self.modules.homeManager.discord
      ];

      social-work.imports = [
        self.modules.homeManager.social
        self.modules.homeManager.mattermost
      ];
    };
  };
}
