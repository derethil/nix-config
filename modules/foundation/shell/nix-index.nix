{
  self,
  inputs,
  ...
}: {
  flake-file.inputs.nix-index-database = {
    inputs.nixpkgs.follows = "nixpkgs";
    url = "github:nix-community/nix-index-database";
  };

  flake.modules = {
    generic.nix-index-config.programs.nix-index-database.comma.enable = true;

    # nix-darwin's programs.nix-index module doesn't expose the
    # enable*Integration options — those exist only on nixos and home-manager.
    nixos.nix-index = {
      imports = [
        inputs.nix-index-database.nixosModules.nix-index
        self.modules.generic.nix-index-config
      ];

      programs.nix-index = {
        enableBashIntegration = true;
        enableFishIntegration = true;
        enableZshIntegration = true;
      };
    };

    darwin.nix-index.imports = [
      inputs.nix-index-database.darwinModules.nix-index
      self.modules.generic.nix-index-config
    ];

    homeManager.nix-index = {
      imports = [
        inputs.nix-index-database.homeModules.nix-index
        self.modules.generic.nix-index-config
      ];

      programs.nix-index = {
        enableBashIntegration = true;
        enableFishIntegration = true;
        enableZshIntegration = true;
      };
    };
  };
}
