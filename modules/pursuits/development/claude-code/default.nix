{self, ...}: {
  flake.modules.homeManager.claude-code = {pkgs, ...}: {
    imports = [self.modules.homeManager.mcp];

    home.packages = [
      pkgs.python3
    ];

    programs.claude-code = {
      enable = true;
      commandsDir = ./_commands;

      context = ''
        Do not over-plan. For simple tasks, just make the change directly.
        Do not explore project context, ask clarifying questions, propose
        multiple approaches, or write design docs unless explicitly asked.
        Default to action. Bias toward making the change immediately.

        Never commit. When changes are ready to commit, just tell me
        and stop. Do not run git commit under any circumstances.

        This system runs NixOS. You can run any command not installed on
        the system using comma (,) which uses nix-index to find and run
        packages from nixpkgs ephemerally. For example: ", fastfetch"
        will run fastfetch without it being installed. Alternatively, you can run any
        command in a Nix shell using "nix-shell -p <package>".

        When you list your sources after using online search, you must output the
        source as raw URLs rather than markdown links. This is to ensure
        I can open the links directly in my browser without having to copy and paste them.

        When giving me a command to run, also run it through Bash as
        `printf 'the-command' | wl-copy` to copy it to my clipboard, then show it in a code block.
      '';

      enableMcpIntegration = true;

      settings = {
        enabledPlugins = {
          "pr-review-toolkit@claude-plugins-official" = true;
          "superpowers@claude-plugins-official" = true;
        };

        includeCoAuthoredBy = false;
        model = "sonnet";

        permissions = {
          defaultMode = "auto";
          deny = ["Bash(git commit*)"];
        };

        showThinkingSummaries = true;
        skipAutoPermissionsPrompt = true;
      };
    };
  };
}
