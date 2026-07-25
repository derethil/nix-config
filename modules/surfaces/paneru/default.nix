{
  self,
  inputs,
  ...
}: {
  flake-file.inputs.paneru = {
    inputs.nixpkgs.follows = "nixpkgs";
    url = "github:karinushka/paneru";
  };

  flake.modules = {
    darwin = {
      paneru = {
        imports = [
          self.modules.darwin.darwin-surfaces
          self.modules.darwin.mediamate
          self.modules.darwin.paneru-nix
        ];

        services.paneru.enable = true;
      };

      paneru-nix.imports = [inputs.paneru.darwinModules.paneru];
    };

    homeManager.paneru.imports = [
      self.modules.homeManager.fonts
      self.modules.homeManager.wallpaper
    ];
  };
}
