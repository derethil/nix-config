# DO-NOT-EDIT. This file was auto-generated using github:vic/flake-file.
# Use `nix run .#write-flake` to regenerate it.
{
  description = "Personal NixOS, Nix Darwin, and Home Manager configurations";

  outputs =
    inputs@{ flake-parts, import-tree, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } (import-tree [
      ./modules
      ./hosts
      ./overlays
      ./templates
    ]);

  inputs = {
    bongocat = {
      url = "github:saatvik333/wayland-bongocat";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";
    dank-material-shell = {
      url = "github:AvengeMedia/DankMaterialShell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dms-plugin-registry = {
      url = "github:AvengeMedia/dms-plugin-registry";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-file.url = "github:vic/flake-file";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence = {
      url = "github:nix-community/impermanence";
      inputs = {
        home-manager.follows = "";
        nixpkgs.follows = "";
      };
    };
    import-tree.url = "github:vic/import-tree";
    it87 = {
      url = "github:frankcrawford/it87/h2ram-mmio";
      flake = false;
    };
    khal-notify = {
      url = "github:martiert/khal_notifications";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mac-app-util.url = "github:hraban/mac-app-util";
    niri-nix.url = "git+https://codeberg.org/BANanaD3V/niri-nix";
    niri-smart-workspace = {
      url = "github:derethil/niri-smart-workspace";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-citizen = {
      url = "github:LovingMelody/nix-citizen";
      inputs.nix-gaming.follows = "nix-gaming";
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
    nix-gaming.url = "github:fufexan/nix-gaming";
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpak = {
      url = "github:nixpak/nixpak";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-szurubooru-pr.url = "github:RatCornu/nixpkgs/szurubooru";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nvim-config.url = "github:derethil/nvim-config";
    quickshell = {
      url = "git+https://github.com/quickshell-mirror/quickshell?ref=master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    secrets = {
      url = "git+ssh://git@github.com/derethil/nix-secrets?ref=main";
      flake = false;
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    systems.url = "github:nix-systems/default";
    tmux-power-zoom = {
      url = "github:jaclu/tmux-power-zoom";
      flake = false;
    };
    tmux-theme = {
      url = "github:derethil/tmux-theme";
      flake = false;
    };
    yazi-gruvbox-dark = {
      url = "github:bennyyip/gruvbox-dark.yazi";
      flake = false;
    };
  };
}
