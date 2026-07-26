# DO-NOT-EDIT. This file was auto-generated using github:vic/flake-file.
# Use `nix run .#write-flake` to regenerate it.
{
  description = "Personal NixOS, Nix Darwin, and Home Manager configurations";

  inputs = {
    flake-file.url = "github:vic/flake-file";

    bongocat = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:saatvik333/wayland-bongocat";
    };

    cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

    dank-greeter = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:AvengeMedia/dank-greeter";
    };

    dank-material-shell = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:AvengeMedia/DankMaterialShell";
    };

    disko = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/disko";
    };

    dms-plugin-registry = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:AvengeMedia/dms-plugin-registry";
    };

    flake-parts = {
      inputs.nixpkgs-lib.follows = "nixpkgs";
      url = "github:hercules-ci/flake-parts";
    };

    home-manager = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/home-manager/release-26.05";
    };

    impermanence = {
      inputs = {
        home-manager.follows = "";
        nixpkgs.follows = "";
      };

      url = "github:nix-community/impermanence";
    };

    import-tree.url = "github:vic/import-tree";

    it87 = {
      flake = false;
      url = "github:frankcrawford/it87/h2ram-mmio";
    };

    khal-notify = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:martiert/khal_notifications";
    };

    mac-app-util.url = "github:mcflis/mac-app-util/fix/missing-icons";
    niri-nix.url = "git+https://codeberg.org/BANanaD3V/niri-nix";

    niri-smart-workspace = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:derethil/niri-smart-workspace";
    };

    nix-citizen = {
      inputs.nix-gaming.follows = "nix-gaming";
      url = "github:LovingMelody/nix-citizen";
    };

    nix-darwin = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:LnL7/nix-darwin/nix-darwin-26.05";
    };

    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
    nix-gaming.url = "github:fufexan/nix-gaming";

    nix-index-database = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/nix-index-database";
    };

    nixpak = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nixpak/nixpak";
    };

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-szurubooru-pr.url = "github:RatCornu/nixpkgs/szurubooru";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    nur = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/NUR";
    };

    nvim-config.url = "github:derethil/nvim-config";

    paneru = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:karinushka/paneru";
    };

    pedantix.url = "github:Swarsel/pedantix";
    quadlet-nix.url = "github:SEIAROTg/quadlet-nix";

    quickshell = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "git+https://github.com/quickshell-mirror/quickshell?ref=master";
    };

    self.submodules = true;

    sops-nix = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:Mic92/sops-nix";
    };
    tmux-power-zoom = {
      flake = false;
      url = "github:jaclu/tmux-power-zoom";
    };

    tmux-theme = {
      flake = false;
      url = "github:derethil/tmux-theme";
    };

    yazi-gruvbox-dark = {
      flake = false;
      url = "github:bennyyip/gruvbox-dark.yazi";
    };
  };

  outputs = inputs @ {
    flake-parts,
    import-tree,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} (
      import-tree [
        ./flake
        ./hosts
        ./modules
        ./overlays
        ./templates
      ]
    );
}
