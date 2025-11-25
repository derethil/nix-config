{
  description = "My Home Manager Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    # qt5 has been flagged as unmaintained and insecure, so we must explicitly
    # permit its usage to run Stremio. However, since insecure packages are not
    # built by Hydra once marked with known vulnerabilities, we use a pinned,
    # older nixpkgs revision from before that change. This ensures Hydra can
    # provide prebuilt binaries, since building qt5 locally is too heavy.
    nixpkgs-for-stremio.url = "nixpkgs/5135c59491985879812717f4c9fea69604e7f26f";

    # Nix

    snowfall-lib = {
      url = "github:snowfallorg/lib";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager-unstable = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    impermanence = {
      url = "github:nix-community/impermanence";
    };

    chaotic = {
      url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    };

    # Darwin

    darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mac-app-util = {
      url = "github:hraban/mac-app-util";
    };

    # Nix Utils

    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-flatpak = {
      url = "github:gmodena/nix-flatpak/?ref=latest";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Secrets

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    secrets = {
      url = "git+ssh://git@github.com/derethil/nix-secrets?ref=main";
      flake = false;
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

    nix-gaming = {
      url = "github:fufexan/nix-gaming";
    };

    # CLI

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

    # Hyprland

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

    # Niri

    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Desktop Shells

    glace-shell = {
      url = "github:derethil/glace-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    quickshell = {
      url = "git+https://github.com/quickshell-mirror/quickshell?ref=master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dank-material-shell = {
      url = "github:AvengeMedia/DankMaterialShell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dms-official-plugins = {
      url = "github:AvengeMedia/dms-plugins";
      flake = false;
    };
    dms-calculator = {
      url = "github:rochacbruno/DankCalculator";
      flake = false;
    };
    dms-power-usage = {
      url = "github:Daniel-42-z/dms-power-usage";
      flake = false;
    };
    dms-emoji-launcher = {
      url = "github:devnullvoid/dms-emoji-launcher";
      flake = false;
    };

    khal-notify = {
      url = "github:martiert/khal_notifications";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {snowfall-lib, ...} @ inputs: let
    common-modules = snowfall-lib.snowfall.internal-lib.fs.get-default-nix-files-recursive ./modules/common;
    system-common-modules = snowfall-lib.snowfall.internal-lib.fs.get-default-nix-files-recursive ./modules/system-common;
  in (snowfall-lib.mkFlake {
    inherit inputs;
    src = ./.;

    snowfall.namespace = "glace";

    channels-config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
    };

    templates = {
      dragonarmy-npm-golang.description = "A template for Node.js and Go development using devenv";
      npm.description = "A template for Node.js development using devenv";
      python.description = "A template for Python development using devenv and uv";
    };

    overlays = with inputs; [
      niri.overlays.niri
      firefox-addons.overlays.default
    ];

    systems.modules.darwin = with inputs;
      nixpkgs.lib.flatten [
        sops-nix.darwinModules.sops
        mac-app-util.darwinModules.default
        nvim-config.darwinModules.nvim-config
        nix-index-database.darwinModules.nix-index
        common-modules
        system-common-modules
      ];

    systems.modules.nixos = with inputs;
      nixpkgs.lib.flatten [
        nix-flatpak.nixosModules.nix-flatpak
        sops-nix.nixosModules.sops
        impermanence.nixosModules.impermanence
        nvim-config.nixosModules.nvim-config
        nix-gaming.nixosModules.pipewireLowLatency
        nix-gaming.nixosModules.platformOptimizations
        chaotic.nixosModules.nyx-cache
        chaotic.nixosModules.nyx-overlay
        chaotic.nixosModules.nyx-registry
        nix-index-database.nixosModules.nix-index
        common-modules
        system-common-modules
      ];

    homes.modules = with inputs;
      nixpkgs.lib.flatten [
        glace-shell.flakeModules.default
        sops-nix.homeManagerModules.sops
        mac-app-util.homeManagerModules.default
        nvim-config.homeManagerModules.nvim-config
        impermanence.homeManagerModules.impermanence
        dank-material-shell.homeModules.dankMaterialShell.default
        niri.homeModules.niri
        nix-index-database.homeModules.nix-index
        common-modules
      ];
  });

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://derethil.cachix.org"
      "https://hyprland.cachix.org"
      "https://niri.cachix.org"
      "https://chaotic-nyx.cachix.org/"
    ];

    extra-trusted-public-keys = [
      "derethil.cachix.org-1:4v8v6Oo2UHdB3FKutgQ2z3O9L++ukejhGvQFg6Pjsfc="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
      "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
    ];
  };
}
