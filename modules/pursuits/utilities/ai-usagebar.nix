{inputs, ...}: {
  flake-file.inputs.ai-usagebar = {
    inputs.nixpkgs.follows = "nixpkgs";
    url = "github:akitaonrails/ai-usagebar";
  };

  flake.modules.homeManager.ai-usagebar = {pkgs, ...}: {
    home.packages = [
      inputs.ai-usagebar.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
  };
}
