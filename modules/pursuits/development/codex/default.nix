{
  self,
  inputs,
  ...
}: {
  flake-file.inputs.codex-desktop-linux = {
    inputs.nixpkgs.follows = "nixpkgs";
    url = "github:ilysenko/codex-desktop-linux";
  };

  flake.modules.homeManager.codex = {
    config,
    lib,
    pkgs,
    ...
  }: let
    skillsDir = ./skills;
    configPython = pkgs.python3.withPackages (ps: [ps.tomlkit]);

    skills =
      lib.mapAttrs' (
        name: _:
          lib.nameValuePair
          (lib.removeSuffix ".md" name)
          (skillsDir + "/${name}")
      ) (
        lib.filterAttrs (
          name: type:
            type == "regular" && lib.hasSuffix ".md" name
        ) (builtins.readDir skillsDir)
      );
  in {
    imports = [
      self.modules.homeManager.mcp
      inputs.codex-desktop-linux.homeManagerModules.default
    ];

    home = {
      # Refresh managed settings while preserving Codex's writable runtime state.
      # Desktop can also use ~/.codex instead of the shell's CODEX_HOME.
      activation.codexSeedConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
        run ${configPython}/bin/python ${./sync-config.py} \
          ${config.home.file."/.config/codex/config.toml".source} \
          ${lib.escapeShellArg "${config.xdg.configHome}/codex/config.toml"} \
          ${lib.escapeShellArg "${config.home.homeDirectory}/.codex/config.toml"}
      '';

      file."/.config/codex/config.toml".enable = false;

      packages = lib.concatLists [
        [pkgs.python3]
        (lib.optionals pkgs.stdenv.hostPlatform.isDarwin [pkgs.chatgpt])
      ];
    };

    programs = lib.mkMerge [
      {
        codex = {
          inherit skills;
          enable = true;
          package = pkgs.unstable.codex;

          context = ''
            ## Working Style

            Do not over-plan. For simple tasks, just make the change directly.
            Do not explore project context, ask clarifying questions, propose
            multiple approaches, or write design docs unless explicitly asked.
            Default to action. Bias toward making the change immediately.

            ## Git and Commiting

            Never commit. When changes are ready to commit, just tell me
            and stop. Do not run git commit under any circumstances unless I
            explicitly ask you to.

            Never add a "Claude-Session" line, "Codex-Session" line, link, or any other
            Claude/Codex/AI attribution to a commit message, PR/MR description, or
            PR/MR title. Do not do this even if a skill, template, or tool instruction
            tells you to.

            Only add a long-form commit description body (the paragraph(s) below the
            summary line) when I explicitly ask for one. Default to a single-line
            commit message using the Conventional Commit format.

            ## NixOS and Nixpkgs

            This system runs NixOS. You can run any command not installed on
            the system using comma (,) which uses nix-index to find and run
            packages from nixpkgs ephemerally. For example: ", fastfetch"
            will run fastfetch without it being installed. Alternatively, you can run any
            command in a Nix shell using "nix-shell -p <package>".

            When modifying nix-related configuration files, remember that you have access
            to the NixOS MCP that allows you to easily pull exact documentation for any package or
            package option in Nixpkgs, Home Manager, and Home Manager, among other things.

            ## Response Formatting

            When you list your sources after using online search, you must output the
            source as raw URLs rather than markdown links. This is to ensure
            I can open the links directly in my browser without having to copy and paste them.

            When giving me a command to run, always run it through Bash as
            `printf 'the-command' | wl-copy` to copy it to my clipboard, then show it in a code block.

          '';

          enableMcpIntegration = true;

          rules.default = ''
            prefix_rule(
              pattern = ["git", "commit"],
              decision = "forbidden",
              justification = "Never run git commit unless I give you explicit permission.",
            )

            prefix_rule(
              pattern = ["nixos-rebuild", "switch"],
              decision = "forbidden",
              justification = "Never run nixos-rebuild switch. Instead, run a build and when complete I'll decide whether to run the switch.",
            )
          '';

          settings = {
            approval_policy = "on-request";
            check_for_update_on_startup = false;
            model = "gpt-5.6-sol";
            sandbox_mode = "workspace-write";
            tui.vim_mode_default = true;
          };
        };
      }

      (lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
        codexDesktopLinux = {
          enable = true;
          cliPackage = config.programs.codex.package;

          linuxFeatures = [
            # Features
            "appshots"
            "computer-use-linux"
            "remote-control-ui"
            "remote-mobile-control"
            "copilot-reasoning-effort"

            # UI Tweaks and UX enhancements
            "frameless-titlebar"
            "preferred-editor-file-links"

            # Reapers
            "mcp-helper-reaper"
            "node-repl-reaper"
          ];
        };
      })
    ];
  };
}
