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
      shellAbbrs = config.cli.abbreviations;
      shellAliases = config.cli.aliases;

      interactiveShellInit = ''
        fish_vi_key_bindings
        set fish_cursor_default     block      blink
        set fish_cursor_insert      line       blink
        set fish_cursor_replace_one underscore blink
        set fish_cursor_visual      block
        ${lib.optionalString config.tools.aws-cli.enable "complete --command aws --no-files --arguments '(begin; set --local --export COMP_SHELL fish; set --local --export COMP_LINE (commandline); aws_completer | sed \"s/ \\$//\"; end)'"}
      '';

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
