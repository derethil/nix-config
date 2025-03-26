{pkgs, ...}: {
  imports = [
    ./fish
    ./direnv.nix
    ./git.nix
    ./starship.nix
    ./thefuck.nix
    ./trashy.nix
    ./zoxide.nix
  ];

  home.packages = with pkgs; [
    bat # Better cat
    bsdtar # Archiver
    bottom # System monitor
    diff-so-fancy # Better diff
    duf # Disk Usage
    ncdu
    eza # Better ls
    fd # Better find
    fzf # Fuzzy finder
    git-open # Open git repo in browser
    glow # Markdown viewer
    httpie # Better curl
    hwinfo # Hardware info
    jira-cli-go # Jira CLI
    jq # JSON processor
    libqalculate # Calculator
    ripgrep # Better grep
    scc # Project statistics
    tldr # Command help
    unar # Unarchiver

    # Nix Tools
    alejandra # Formatter
    nixfmt-rfc-style
    nvd # Differ
    nix-diff # More detailed differ
    nh # Nix command wrapper
  ];
}
