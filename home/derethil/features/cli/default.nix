{pkgs, ...}: {
  imports = [
  ];

  home.packages = with pkgs; [
    bat # Better cat
    bottom # System monitor
    diff-so-fancy # Better diff
    duf # Disk Usage
    ncdu
    eza # Better ls
    fd # Better find
    git-open # Open git repo in browser
    httpie # Better curl
    jira-cli-go # Jira CLI
    jq # JSON processor
    ripgrep # Better grep
    scc # Project statistics
    tldr # Command help
    thefuck # I fucked up
    zoxide # Better cd

    # Nix Tools
    alejandra # Formatter
    nixfmt-rfc-style
    nvd # Differ
    nix-diff # More detailed differ
    nh # Nix command wrapper
  ];
}
