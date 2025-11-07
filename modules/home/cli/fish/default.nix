{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.glace.cli.fish;
in {
  imports = [
    ./theme.nix
  ];

  config = mkIf cfg.enable {
    programs.fish = {
      enable = true;
      generateCompletions = true;
      shellAbbrs = config.glace.cli.abbreviations;
      shellAliases = config.glace.cli.aliases;

      interactiveShellInit = ''
        set fish_greeting
        fish_vi_key_bindings
        set fish_cursor_default     block      blink
        set fish_cursor_insert      line       blink
        set fish_cursor_replace_one underscore blink
        set fish_cursor_visual      block
        ${lib.optionalString config.glace.tools.development.aws-cli.enable "complete --command aws --no-files --arguments '(begin; set --local --export COMP_SHELL fish; set --local --export COMP_LINE (commandline); aws_completer | sed \"s/ \\$//\"; end)'"}
      '';

      functions = {
        activate = "source ./.venv/bin/activate.fish";
        go-coverage = lib.readFile ./functions/go_coverage.fish;
      };
    };

    home.packages = with pkgs.fishPlugins; [
      fzf
      done
    ];
  };
}
