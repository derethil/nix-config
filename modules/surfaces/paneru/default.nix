{
  self,
  inputs,
  ...
}: {
  flake-file.inputs = {
    paneru = {
      url = "github:karinushka/paneru";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  flake.modules = {
    darwin.paneru-nix = {
      imports = [inputs.paneru.darwinModules.paneru];
    };

    homeManager.paneru = {
      imports = [
        self.modules.homeManager.fonts
        self.modules.homeManager.wallpaper
      ];
    };

    darwin.paneru = {
      imports = [
        self.modules.darwin.paneru-nix
        self.modules.darwin.darwin-surfaces
        self.modules.darwin.mediamate
      ];

      services.paneru = {
        enable = true;
      };
    };
  };
}
