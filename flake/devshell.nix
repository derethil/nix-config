{
  perSystem = {
    pkgs,
    inputs',
    ...
  }: {
    devShells.default = pkgs.mkShell {
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
  };
}
