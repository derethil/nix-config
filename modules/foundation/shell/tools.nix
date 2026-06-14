{
  self,
  lib,
  ...
}: let
  inherit (lib) flatten optionals mkMerge;

  common-aliases = {
    l = "eza -la --icons --group-directories-first --time-style=relative";
    lt = "eza --tree --icons --group-directories-first --level=3";
    cat = "bat";
  };

  common-pkgs = pkgs:
    with pkgs; [
      bat
      bottom
      diff-so-fancy
      duf
      eza
      fd
      fzf
      gdu
      glow
      httpie
      jq
      libarchive
      ripgrep
      rsync
      scc
      tldr
      unar
      watchexec
      just

      alejandra
      nh
      nix-diff
      dix
      nixfmt
      nvd
      nix-inspect
    ];
in {
  flake.modules.nixos.tools = {pkgs, ...}: {
    imports = [self.modules.nixos.shell-consumer];

    environment.systemPackages = common-pkgs pkgs;
    shell.aliases = common-aliases;
  };

  flake.modules.darwin.tools = {pkgs, ...}: {
    imports = [self.modules.darwin.shell-consumer];

    environment.systemPackages = common-pkgs pkgs;
    shell.aliases = common-aliases;
  };

  flake.modules.homeManager.tools = {pkgs, ...}: {
    imports = [self.modules.homeManager.shell-consumer];

    shell.aliases = mkMerge [
      common-aliases
      {
        del = "gtrash put";
        wcl = "wl-copy";
      }
    ];

    programs = {
      direnv = {
        enable = true;
        nix-direnv.enable = true;
      };
      zoxide = {
        enable = true;
      };
    };

    home.packages = with pkgs;
      flatten [
        (common-pkgs pkgs)
        [
          chafa
          gtrash
        ]
        (optionals pkgs.stdenv.isLinux [
          hwinfo
          wl-clipboard
        ])
      ];
  };
}
