{inputs, ...}: {
  flake-file.inputs.git-hooks = {
    inputs.nixpkgs.follows = "nixpkgs";
    url = "github:cachix/git-hooks.nix";
  };

  imports = [inputs.git-hooks.flakeModule];

  perSystem = {
    config,
    pkgs,
    inputs',
    ...
  }: {
    devShells.default = pkgs.mkShell {
      inherit (config.pre-commit) shellHook;

      packages = with pkgs; [
        # Task runner
        just

        # Formatters
        alejandra
        inputs'.pedantix.packages.pedantix-wrapped

        # Linters
        statix
        deadnix

        # Nix utilities
        nh
        dix

        # Secrets & deployment
        sops
        age
        ssh-to-age
        nixos-anywhere

        # General utilities
        fd
        jq
        rsync
      ];
    };

    pre-commit = {
      # `just lint check` and the installed hook already cover this; running every
      # hook again in the sandbox on each `nix flake check` only costs time.
      check.enable = false;

      settings = {
        # Rust reimplementation of pre-commit; ~10x faster to install and run,
        # and what devenv defaults to.
        package = pkgs.prek;

        hooks = {
          deadnix.enable = true;

          pedantix = {
            enable = true;
            entry = "${config.formatter}/bin/pedantix";
            files = "\\.nix$";
            name = "pedantix";
          };

          statix.enable = true;
        };
      };
    };
  };
}
