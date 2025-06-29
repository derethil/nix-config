{
  description = "My Home Manager Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.05";

    # Nix

    snowfall-lib = {
      url = "github:snowfallorg/lib";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Applications

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    trashy = {
      url = "github:oberblastmeister/trashy";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Tmux Plugins

    tmux-theme = {
      url = "github:derethil/tmux-theme";
      flake = false;
    };

    tmux-power-zoom = {
      url = "github:jaclu/tmux-power-zoom";
      flake = false;
    };
  };

  outputs = {snowfall-lib, ...} @ inputs: (snowfall-lib.mkFlake {
    inherit inputs;
    src = ./.;
    channels-config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
    };
  });
}
