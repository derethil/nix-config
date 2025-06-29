{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with internal; let
  cfg = config.cli.fish;
in {
  options.cli.fish = {
    enable = mkBoolOpt false "Whether to enable the Fish shell.";
  };

  config = mkIf cfg.enable {
    programs.fish = {
      enable = true;
      generateCompletions = true;

      interactiveShellInit = ''
        fish_vi_key_bindings
        set fish_cursor_default     block      blink
        set fish_cursor_insert      line       blink
        set fish_cursor_replace_one underscore blink
        set fish_cursor_visual      block
        ${lib.optionalString config.tools.aws-cli.enable "complete --command aws --no-files --arguments '(begin; set --local --export COMP_SHELL fish; set --local --export COMP_LINE (commandline); aws_completer | sed \"s/ \\$//\"; end)'"}
      '';

      shellAbbrs = {
        be = "bundle exec";
      };

      shellAliases = {
        l = "eza -la --icons --group-directories-first --time-style=relative";
        lt = "eza --tree --icons --group-directories-first --level=3";
        cat = "bat";
        btm = "btm --enable_gpu";
        del = "trashy put";
        nv = "nvim";
        udb = "sudo updatedb";
        agsv2 = "ags run --directory ~/.config/astal";
        wget = "wget --hsts-file=$XDG_DATA_HOME/wget-hsts";
        hueadm = "hueadm --config ~/.config/.hueadm.json";
      };

      functions = {
        activate = "source ./.venv/bin/activate.fish";
        fish_greeting = lib.readFile ./functions/fish_greeting.fish;
        go-coverage = lib.readFile ./functions/go_coverage.fish;
      };
    };

    home.packages = with pkgs.fishPlugins; [
      fzf
      done
    ];
  };
}
