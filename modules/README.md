# Modules

Everything that isn't a host or a template. Each subdirectory is a top-level
flake-parts module merging into `flake.modules.*`.

## Layout

- `foundation/`: baseline module that every host imports, like nix settings,
  shell config, openssh, neovim, sudo
- `machine/`: hardware-adjacent stuff like boot/kernel config, drivers,
  bluetooth, networking, system daemons
- `surfaces/`: desktop and UI layer, including niri, macOS settings, desktop
  utilities and themes
- `pursuits/`: user-facing apps grouped by purpose, like browsers, comms,
  development, gaming, media, utilities
- `bridges/`: platform integrations e.g. flatpak on NixOS and homebrew,
  mac-app-util, keychain on darwin
- `hosting/`: self-hosted services
- `flake/`: internal flake plumbing, including the formatter, factory,
  flake-file, and flake-root

## Top-level files

- `lib.nix`: small Nix helpers like `mergeStrict` and `hasPackage`
- `systems.nix`: supported systems for flake outputs
- `nixpkgs.nix`, `home-manager.nix`, `nix-darwin.nix`: input wiring and
  `follows`
