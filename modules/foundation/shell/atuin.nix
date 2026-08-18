{self, ...}: {
  flake.modules.homeManager.atuin = {
    config,
    lib,
    pkgs,
    ...
  }: let
    inherit (lib) getExe mkAfter;

    cfg = config.programs.atuin;
    atuin = getExe cfg.package;
  in {
    imports = [self.modules.homeManager.secrets];

    home.activation.atuinLogin = lib.hm.dag.entryAfter ["sops-nix"] ''
      if ! ${atuin} status >/dev/null 2>&1; then
        # On MacOS sops decryption runs async, so wait until secrets are available
        for _ in $(seq 1 50); do
          if [ -s "${config.sops.secrets."foundation/atuin/password".path}" ] \
            && [ -s "${config.sops.secrets."foundation/atuin/key".path}" ]; then
            break
          fi
          sleep 0.2
        done

        run ${atuin} login \
          -u derethil \
          -p "$(cat ${config.sops.secrets."foundation/atuin/password".path})" \
          -k "$(cat ${config.sops.secrets."foundation/atuin/key".path})" \
          || echo "atuin login failed (offline, or secrets not decrypted yet?) -- will retry next activation" >&2
      fi
    '';

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
          command_chaining = true;
          enter_accept = true;
          filter_mode = "global";
          filter_mode_shell_up_key_binding = "session";
          inline_height = 25;
          inline_height_shell_up_key_binding = 15;

          keymap_cursor = {
            vim_insert = "blink-bar";
            vim_normal = "blink-block";
          };

          keymap_mode = "vim-insert";
          logs.dir = "${config.xdg.stateHome}/atuin/logs";
          search.authors = ["$all-agent" "$all-user"];
          search_mode = "daemon-fuzzy";
          search_mode_shell_up_key_binding = "fuzzy";
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

      fish.interactiveShellInit = mkAfter ''
        bind --mode default k '_atuin_bind_up'
        bind --mode default j '_atuin_bind_up'
      '';
    };

    sops.secrets = {
      "foundation/atuin/key".path = "${config.home.homeDirectory}/.local/share/atuin/key";
      "foundation/atuin/password" = {};
    };
  };
}
