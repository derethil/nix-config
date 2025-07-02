{
  pkgs,
  lib,
  ...
}:
with lib;
with internal; let
  cfg = config.cli.misc;
in {
  options.cli.misc = {
    enabled = mkEnableOption "Whether to enable the various CLI tools and utilities.";
  };

  config = mkIf cfg.enabled {
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
      glow # Markdown viewer
      httpie # Better curl
      hwinfo # Hardware info
      jq # JSON processor
      libqalculate # CLI Calculator
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
  };
}
