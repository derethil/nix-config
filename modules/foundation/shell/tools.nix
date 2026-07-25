{
  self,
  lib,
  ...
}: let
  inherit (lib) flatten mkMerge optionals;

  common-aliases = {
    cat = "bat";
    l = "eza -la --icons --group-directories-first --time-style=relative";
    lt = "eza --tree --icons --group-directories-first --level=3";
  };

  common-pkgs = pkgs:
    with pkgs; [
      # nix tools
      alejandra
      # terminal utilities
      bat
      bottom
      diff-so-fancy
      dix
      # file management
      duf
      eza
      fd
      fzf
      gdu
      glow
      httpie
      jq
      libarchive
      nh
      nix-inspect
      nix-tree
      ripgrep
      rsync
      scc
      tldr
      unar
      watchexec
    ];
in {
  flake.modules = {
    nixos.tools = {pkgs, ...}: {
      imports = [self.modules.nixos.shell-consumer];
      environment.systemPackages = common-pkgs pkgs;
      shell.aliases = common-aliases;
    };

    darwin.tools = {pkgs, ...}: {
      imports = [self.modules.darwin.shell-consumer];
      environment.systemPackages = common-pkgs pkgs;
      shell.aliases = common-aliases;
    };

    homeManager.tools = {pkgs, ...}: {
      imports = [
        self.modules.homeManager.just
        self.modules.homeManager.shell-consumer
      ];

      home.packages = with pkgs;
        flatten [
          (common-pkgs pkgs)
          (optionals pkgs.stdenv.isLinux [
            hwinfo
            wl-clipboard
          ])
          [
            chafa
          ]
        ];

      programs = {
        direnv = {
          enable = true;
          nix-direnv.enable = true;
        };

        zoxide.enable = true;
      };

      shell.aliases = mkMerge [
        common-aliases
        {
          wcl = "wl-copy";
        }
      ];
    };
  };
}
