{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
with internal; let
  cfg = config.cli.misc;
in {
  options.cli.misc = {
    enable = mkEnableOption "Whether to enable the various CLI tools and utilities.";
  };

  config = mkIf cfg.enable {
    cli.aliases = {
      l = "eza -la --icons --group-directories-first --time-style=relative";
      lt = "eza --tree --icons --group-directories-first --level=3";
      cat = "bat";
      btm = "btm --enable_gpu";
      udb = "sudo updatedb";
    };

    home.packages = with pkgs;
      flatten [
        # Cross-platform packages
        [
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
          jq # JSON processor
          libqalculate # CLI Calculator
          ripgrep # Better grep
          rsync # File synchronization
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
        ]

        # Linx-only packages
        (lib.optionals pkgs.stdenv.hostPlatform.isLinux [
          hwinfo # Hardware info
        ])
      ];
  };
}
