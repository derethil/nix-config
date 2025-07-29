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

    nix-flatpak = {
      url = "github:gmodena/nix-flatpak/?ref=latest";
    };

    # Applications

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    icon-browser = {
      url = "github:aylur/icon-browser";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nvim-config = {
      url = "github:derethil/nvim-config";
    };

    # CLI

    trashy = {
      url = "github:oberblastmeister/trashy";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    tmux-theme = {
      url = "github:derethil/tmux-theme";
      flake = false;
    };
    tmux-power-zoom = {
      url = "github:jaclu/tmux-power-zoom";
      flake = false;
    };

    rust-system-scripts = {
      url = "github:derethil/rust-system-scripts";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Desktop

    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
      inputs.nixpkgs.follows = "hyprland/nixpkgs";
    };
    hyprXPrimary = {
      url = "github:zakk4223/hyprXPrimary";
      inputs.hyprland.follows = "hyprland";
      inputs.nixpkgs.follows = "hyprland/nixpkgs";
    };

    glace-shell = {
      url = "github:derethil/glace-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {snowfall-lib, ...} @ inputs: (snowfall-lib.mkFlake {
    inherit inputs;
    src = ./.;
    channels-config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
    };
    homes.modules = with inputs; [
      nix-flatpak.homeManagerModules.nix-flatpak
    ];
    nix.settings = {
      substituters = [
        "https://nix-community.cachix.org"
        "https://hyprland.cachix.org"
        "https://cache.nixos.org"
      ];
      trusted-substituters = [
        "https://nix-community.cachix.org"
        "https://hyprland.cachix.org"
        "https://cache.nixos.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      ];
    };
  });
}
