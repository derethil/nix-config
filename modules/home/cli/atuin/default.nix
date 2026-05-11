{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkAfter;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.cli.atuin;
in {
  options.glace.cli.atuin = {
    enable = mkBoolOpt false "Whether to enable atuin.";
  };

  config = mkIf cfg.enable {
    secrets."services/atuin/key" = {
      path = "${config.home.homeDirectory}/.local/share/atuin/key";
    };

    programs.atuin = {
      enable = true;

      package = pkgs.unstable.atuin;

      enableBashIntegration = config.programs.bash.enable;
      enableFishIntegration = config.programs.fish.enable;
      enableZshIntegration = config.programs.zsh.enable;
      enableNushellIntegration = config.programs.nushell.enable;

      daemon = {
        enable = true;
      };

      settings = {
        style = "compact";
        search_mode = "daemon-fuzzy";
        search_mode_shell_up_key_binding = "daemon-fuzzy";
        enter_accept = true;
        keymap_mode = "vim-insert";

        sync = {
          records = true;
        };

        search = {
          authors = ["$all-user" "$all-agent"];
        };

        logs = {
          dir = "${config.xdg.stateHome}/atuin/logs";
        };
      };
    };

    programs.fish.interactiveShellInit = mkIf config.programs.fish.enable (mkAfter ''
      bind --mode default k '_atuin_search'
      bind --mode default j '_atuin_search'
      bind --mode default up '_atuin_search'
    '');

    programs.claude-code.settings.hooks = mkIf config.programs.claude-code.enable {
      PreToolUse = [
        {
          matcher = "Bash";
          hooks = [
            {
              type = "command";
              command = "atuin hook claude-code";
            }
          ];
        }
      ];
      PostToolUse = [
        {
          matcher = "Bash";
          hooks = [
            {
              type = "command";
              command = "atuin hook claude-code";
            }
          ];
        }
      ];
      PostToolUseFailure = [
        {
          matcher = "Bash";
          hooks = [
            {
              type = "command";
              command = "atuin hook claude-code";
            }
          ];
        }
      ];
    };
  };
}
