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
      check.enable = false;

      settings = {
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
