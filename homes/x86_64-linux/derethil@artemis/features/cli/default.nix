{pkgs, ...}: {
  imports = [
    ./tmux
    ./direnv.nix
    ./starship.nix
    ./zoxide.nix
  ];

  home.packages = with pkgs; [
    bat # Better cat
    libarchive # Archiver / unarchiver
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
    watchexec # Run commands based on file changes

    # Nix Tools
    alejandra # Formatter
    nixfmt-rfc-style
    nvd # Differ
    nix-diff # More detailed differ
    nh # Nix command wrapper
  ];
}
