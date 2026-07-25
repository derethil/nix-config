{
  flake.modules.homeManager.starship = {config, ...}: {
    programs.starship = {
      enable = true;
      enableBashIntegration = config.programs.bash.enable;
      enableFishIntegration = config.programs.fish.enable;
      enableNushellIntegration = config.programs.nushell.enable;
      enableZshIntegration = config.programs.zsh.enable;

      settings = {
        package.disabled = true;
        add_newline = false;
        aws.disabled = false;

        character = {
          error_symbol = "[λ](bold red)";
          success_symbol = "[λ](bold blue)";
          vimcmd_replace_one_symbol = "[Λ](bold purple)";
          vimcmd_replace_symbol = "[Λ](bold purple)";
          vimcmd_symbol = "[Λ](bold green)";
          vimcmd_visual_symbol = "[Λ](bold yellow)";
        };

        cmd_duration.min_time = 1000;

        directory = {
          format = "[$path]($style) [$read_only]($read_only_style)";
          read_only = " ";
          read_only_style = "blue";
          style = "bold blue";
        };

        fill.symbol = " ";
        # this is dumb
        format = "[╭─](bold blue)$username$hostname$localip$shlvl$singularity$kubernetes$directory$vcsh$fossil_branch$fossil_metrics$git_branch$git_commit$git_state$git_metrics$git_status$hg_branch$hg_state$pijul_channel$docker_context$package$c$cmake$cobol$daml$dart$deno$dotnet$elixir$elm$erlang$fennel$fortran$gleam$golang$guix_shell$haskell$haxe$helm$java$julia$kotlin$gradle$lua$nim$nodejs$ocaml$opa$perl$php$pulumi$purescript$python$quarto$raku$rlang$red$ruby$rust$scala$solidity$swift$terraform$typst$vlang$vagrant$zig$buf$nix_shell$conda$meson$spack$memory_usage$aws$gcloud$openstack$azure$nats$direnv$env_var$mise$crystal$custom$sudo$cmd_duration$line_break[╰─](bold blue)$jobs$battery$time$status$os$container$netns$shell$character";
        git_branch.style = "bold cyan";

        git_commit = {
          only_detached = true;
          tag_disabled = false;
        };

        git_metrics.disabled = false;
        nix_shell.symbol = "❄️";
        nodejs.style = "bold green";
        python.symbol = " ";
      };
    };
  };
}
