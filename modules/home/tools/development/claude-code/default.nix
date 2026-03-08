{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.tools.development.claude-code;
in {
  options.glace.tools.development.claude-code = {
    enable = mkBoolOpt false "Whether to enable Claude Code.";
  };

  config = mkIf cfg.enable {
    programs.claude-code = {
      enable = true;
      package = pkgs.claude-code;
      commandsDir = ./commands;
      memory.text = ''
        Do not over-plan. For simple tasks, just make the change directly.
        Do not explore project context, ask clarifying questions, propose
        multiple approaches, or write design docs unless explicitly asked.
        Default to action. Bias toward making the change immediately.

        Never commit. When changes are ready to commit, just tell me
        and stop. Do not run git commit under any circumstances.

        This system runs NixOS. You can run any command not installed on
        the system using comma (,) which uses nix-index to find and run
        packages from nixpkgs ephemerally. For example: ", fastfetch"
        will run fastfetch without it being installed.
      '';
      settings = {
        model = "sonnet";
        includeCoAuthoredBy = false;
        permissions = {
          deny = [
            "Bash(git commit*)"
          ];
        };
        enabledPlugins = {
          "superpowers@claude-plugins-official" = true;
          "serena@claude-plugins-official" = true;
          "pr-review-toolkit@claude-plugins-official" = true;
          "typescript-lsp@claude-plugins-official" = true;
          "gopls-lsp@claude-plugins-official" = true;
        };
      };
    };
  };
}
