{self, ...}: {
  flake.modules = {
    nixos.development.imports = [
      self.modules.nixos.devenv
    ];

    darwin.development.imports = [
      self.modules.darwin.devenv
    ];

    homeManager.development.imports = [
      self.modules.homeManager.aws-cli
      self.modules.homeManager.bruno
      self.modules.homeManager.claude-code
      self.modules.homeManager.devenv
      self.modules.homeManager.jira-cli
      self.modules.homeManager.postgresql-client
    ];
  };
}
