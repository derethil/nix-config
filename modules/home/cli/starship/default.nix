{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.cli.starship;
in {
  options.glace.cli.starship = {
    enable = mkBoolOpt false "Whether to enable starship prompt.";
  };

  config = mkIf cfg.enable {
    programs.starship = {
      enable = true;
      settings = {
        # this is dumb
        format = "[╭─](bold blue)$username$hostname$localip$shlvl$singularity$kubernetes$directory$vcsh$fossil_branch$fossil_metrics$git_branch$git_commit$git_state$git_metrics$git_status$hg_branch$hg_state$pijul_channel$docker_context$package$c$cmake$cobol$daml$dart$deno$dotnet$elixir$elm$erlang$fennel$fortran$gleam$golang$guix_shell$haskell$haxe$helm$java$julia$kotlin$gradle$lua$nim$nodejs$ocaml$opa$perl$php$pulumi$purescript$python$quarto$raku$rlang$red$ruby$rust$scala$solidity$swift$terraform$typst$vlang$vagrant$zig$buf$nix_shell$conda$meson$spack$memory_usage$aws$gcloud$openstack$azure$nats$direnv$env_var$mise$crystal$custom$sudo$cmd_duration$line_break[╰─](bold blue)$jobs$battery$time$status$os$container$netns$shell$character";
        add_newline = false;
        aws.disabled = false;
        character = {
          success_symbol = "[λ](bold blue)";
          error_symbol = "[λ](bold red)";
          vimcmd_symbol = "[Λ](bold green)";
          vimcmd_visual_symbol = "[Λ](bold yellow)";
          vimcmd_replace_symbol = "[Λ](bold purple)";
          vimcmd_replace_one_symbol = "[Λ](bold purple)";
        };
        cmd_duration.min_time = 1000;
        directory = {
          format = "[$path]($style) [$read_only]($read_only_style)";
          style = "bold blue";
          read_only = " ";
          read_only_style = "blue";
        };
        fill.symbol = " ";
        git_branch.style = "bold cyan";
        git_metrics.disabled = false;
        git_commit = {
          tag_disabled = false;
          only_detached = true;
        };
        nodejs.style = "bold green";
        nix_shell.symbol = "❄️";
        package.disabled = true;
        python.symbol = " ";
      };
    };
  };
}
