{
  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      aws.disabled = true;
      character = {
        format = "[╰─](bold blue)$symbol ";
        success_symbol = "[λ](bold blue)";
        error_symbol = "[λ](bold red)";
        vimcmd_symbol = "[Λ](bold green)";
        vimcmd_visual_symbol = "[Λ](bold yellow)";
        vimcmd_replace_symbol = "[Λ](bold purple)";
        vimcmd_replace_one_symbol = "[Λ](bold purple)";
      };
      cmd_duration.min_time = 1000;
      directory = {
        format = "[╭─$path]($style) [$read_only]($read_only_style)";
        style = "bold blue";
        read_only = " ";
        read_only_style = "blue";
      };
      fill.symbol = " ";
      git_branch.style = "bold cyan";
      git_metrics.disabled = false;
      nodejs.style = "bold green";
      package.disabled = true;
      python.symbol = " ";
    };
  };
}
