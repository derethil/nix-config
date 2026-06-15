{self, ...}: {
  flake.modules.homeManager.atuin = {
    config,
    lib,
    pkgs,
    ...
  }: {
    imports = [self.modules.homeManager.secrets];

    sops.secrets."services/atuin/key" = {
      path = "${config.home.homeDirectory}/.local/share/atuin/key";
    };

    programs.atuin = {
      enable = true;
      package = pkgs.unstable.atuin;

      enableBashIntegration = config.programs.bash.enable;
      enableFishIntegration = config.programs.fish.enable;
      enableZshIntegration = config.programs.zsh.enable;
      enableNushellIntegration = config.programs.nushell.enable;

      daemon.enable = true;

      settings = {
        style = "compact";
        search_mode = "daemon-fuzzy";
        search_mode_shell_up_key_binding = "daemon-fuzzy";
        enter_accept = true;
        keymap_mode = "vim-insert";

        sync.records = true;
        search.authors = ["$all-user" "$all-agent"];
        logs.dir = "${config.xdg.stateHome}/atuin/logs";
      };
    };

    programs.fish.interactiveShellInit = lib.mkAfter ''
      bind --mode default k '_atuin_search'
      bind --mode default j '_atuin_search'
      bind --mode default up '_atuin_search'
    '';

    programs.claude-code = let
      atuin-hook = {
        matcher = "Bash";
        hooks = [
          {
            type = "command";
            command = "atuin hook claude-code";
          }
        ];
      };
    in {
      settings.hooks = {
        PreToolUse = [atuin-hook];
        PostToolUse = [atuin-hook];
        PostToolUseFailure = [atuin-hook];
      };
    };
  };
}
