{self, ...}: {
  flake.modules.homeManager.ai.imports = [
    self.modules.homeManager.ai-usagebar
    self.modules.homeManager.claude-desktop
    self.modules.homeManager.codex-desktop
  ];
}
