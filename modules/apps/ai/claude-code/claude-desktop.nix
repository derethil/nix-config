{lib, ...}: {
  flake-file.inputs.llm-agents.url = "github:numtide/llm-agents.nix";

  flake.modules.homeManager.claude-desktop = {pkgs, ...}: {
    config = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
      home.packages = [pkgs.inputs.llm-agents.claude-desktop];
    };
  };
}
