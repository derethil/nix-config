{
  lib,
  inputs,
  ...
}: {
  flake-file = {
    description = "Personal NixOS, Nix Darwin, and Home Manager configurations";

    do-not-edit = ''
      # DO-NOT-EDIT. This file was auto-generated using github:vic/flake-file.
      # Use `just flake write` to regenerate it.
    '';

    formatter = pkgs:
      pkgs.writeShellApplication {
        name = "pedantix";
        runtimeInputs = [inputs.pedantix.packages.${pkgs.stdenv.hostPlatform.system}.pedantix-wrapped];
        text = ''exec pedantix --config ${inputs.self}/pedantix.toml "$@"'';
      };

    inputs = {
      disko = {
        inputs.nixpkgs.follows = "nixpkgs";
        url = "github:nix-community/disko";
      };

      pedantix.url = "github:Swarsel/pedantix";
      self.submodules = true;
    };

    outputs = lib.mkForce ''
      inputs@{flake-parts, import-tree, ...}:
      flake-parts.lib.mkFlake {inherit inputs;} (
        import-tree [
          ./modules
          ./flake
          ./hosts
          ./overlays
          ./templates
        ]
      )
    '';

    write-hooks = [
      {
        index = 10;

        program = pkgs:
          pkgs.writeShellApplication {
            name = "nix-flake-lock";
            runtimeInputs = [pkgs.nix];
            text = "nix flake lock";
          };
      }
    ];
  };

  imports = [
    inputs.flake-file.flakeModules.dendritic
  ];
}
