{self, ...}: {
  flake.modules = {
    homeManager.development = {
      imports = [
        self.modules.homeManager.claude-code
        self.modules.homeManager.devenv
        self.modules.homeManager.jira-cli
        self.modules.homeManager.aws-cli
        self.modules.homeManager.postgresql-client
        self.modules.homeManager.bruno
      ];
    };

    nixos.development = {
      imports = [
        self.modules.nixos.devenv
      ];
    };

    darwin.development = {
      imports = [
        self.modules.darwin.devenv
      ];
    };
  };
}
