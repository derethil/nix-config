{self, ...}: {
  flake.modules.homeManager.atuin = {
    config,
    lib,
    pkgs,
    ...
  }: {
    imports = [self.modules.homeManager.secrets];

    programs = {
      atuin = {
        enable = true;
        package = pkgs.unstable.atuin;
        daemon.enable = true;
        enableBashIntegration = config.programs.bash.enable;
        enableFishIntegration = config.programs.fish.enable;
        enableNushellIntegration = config.programs.nushell.enable;
        enableZshIntegration = config.programs.zsh.enable;

        settings = {
          enter_accept = true;
          keymap_mode = "vim-insert";
          logs.dir = "${config.xdg.stateHome}/atuin/logs";
          search.authors = ["$all-agent" "$all-user"];
          search_mode = "daemon-fuzzy";
          search_mode_shell_up_key_binding = "daemon-fuzzy";
          style = "compact";
          sync.records = true;
        };
      };

      claude-code = let
        atuin-hook = {
          hooks = [
            {
              command = "atuin hook claude-code";
              type = "command";
            }
          ];

          matcher = "Bash";
        };
      in {
        settings.hooks = {
          PostToolUse = [atuin-hook];
          PostToolUseFailure = [atuin-hook];
          PreToolUse = [atuin-hook];
        };
      };

      fish.interactiveShellInit = lib.mkAfter ''
        bind --mode default k '_atuin_search'
        bind --mode default j '_atuin_search'
        bind --mode default up '_atuin_search'
      '';
    };

    sops.secrets."foundation/atuin/key".path = "${config.home.homeDirectory}/.local/share/atuin/key";
  };
}
