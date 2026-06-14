{
  inputs,
  self,
  ...
}: {
  flake-file.inputs.nix-index-database = {
    url = "github:nix-community/nix-index-database";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.generic.nix-index-config = {
    programs.nix-index-database.comma.enable = true;
  };

  # nix-darwin's programs.nix-index module doesn't expose the
  # enable*Integration options — those exist only on nixos and home-manager.
  flake.modules.nixos.nix-index = {
    imports = [
      self.modules.generic.nix-index-config
      inputs.nix-index-database.nixosModules.nix-index
    ];

    programs.nix-index = {
      enableFishIntegration = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
    };
  };

  flake.modules.darwin.nix-index = {
    imports = [
      self.modules.generic.nix-index-config
      inputs.nix-index-database.darwinModules.nix-index
    ];
  };

  flake.modules.homeManager.nix-index = {
    imports = [
      self.modules.generic.nix-index-config
      inputs.nix-index-database.homeModules.nix-index
    ];

    programs.nix-index = {
      enableFishIntegration = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
    };
  };
}
