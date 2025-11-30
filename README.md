<div align="center">

<h3>
  ❄️<br/>
  NixOS Config for <a href="https://github.com/derethil">Derethil</a>
  <img src="https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/misc/transparent.png" height="30" width="0px"/>
</h3>

<p>
    <a href="https://github.com/derethil/nix-config">
      <img src="https://img.shields.io/github/last-commit/derethil/nix-config?style=for-the-badge&color=rgb(54%2C%2058%2C%2079)">
    </a>
    <a href="https://nixos.wiki/wiki/Flakes" target="_blank">
      <img alt="Nix Flakes Ready" src="https://img.shields.io/static/v1?logo=nixos&logoColor=d8dee9&label=Nix%20Flakes&labelColor=5e81ac&message=Ready&color=d8dee9&style=for-the-badge">
    </a>
    <a href="https://github.com/snowfallorg/lib" target="_blank">
      <img alt="Built With Snowfall" src="https://img.shields.io/static/v1?logoColor=d8dee9&label=Built%20With&labelColor=5e81ac&message=Snowfall&color=d8dee9&style=for-the-badge">
    </a>
  </p>

</div>

My Nix configurations for NixOS, Nix Darwin, and Home Manager.

## Usage

### Clone this repository to your local machine

```bash
git clone https://github.com/derethil/nix-config.git ~/.config/nix-config
cd ~/.config/nix-config
```

TODO: Installation instructions with disko and nixos-anywhere

### Development Templates

```plaintext
# Node.js environment
github:derethil/nix-config#npm

# Node.js + Go environment
github:derethil/nix-config#dragonarmy-npm-golang

# Uv-managed Python environment
github:derethil/nix-config#python
```

## Features

Here's an overview of what my Nix configuration offers:

- **[Next-Gen Wayland Compositors](./modules/home/desktop)**: Featuring Niri
  (scrollable tiling) and Hyprland, both optimized for NVIDIA and high-refresh
  displays with VRR support.

- **[Custom Desktop Shells](./modules/home/desktop)**: Dank Material Shell
  support including various third-party plugins to improve productivity and add
  QOL features.

- **[Gaming](./modules/nixos/apps)**: Integrated CachyOS kernel optimization,
  Steam with Proton optimizations, lossless scaling technology, and
  comprehensive launcher and game (Heroic, PrismLauncher, GDLauncher, Sober).

- **[Advanced Security and Impermanence](./modules/system-common)**: BTRFS
  impermanence with encrypted root rollback, SOPS secret management with age
  encryption, and LUKS full-disk encryption with secure boot.

- **[Development](./modules/home/tools)**: Provides my Neovim configuration
  through NVF via a **[custom flake](https://github.com/derethil/nvim-config)**
  as well as comprehensive DevEnv templates and a suite of CLI utilities and
  tool configurations.

- **[Cross-Platform Window Management](./modules/home/desktop)**: AeroSpace
  tiling for macOS with unified keybindings across all platforms.

- **[Privacy-Hardened Browsing](./modules/home/apps/firefox)**: Firefox with
  custom CSS theming and vim bindings among other addons and privacy
  configurations including telemetry disabling.

## System Architecture

### Hosts

- **Athena** (x86_64-linux): NixOS desktop with NVIDIA optimizations
- **Hestia** (aarch64-darwin): Apple Silicon macOS development machine

### Core Technologies

- **Snowfall Lib**: Modular configuration management with automatic imports
- **Home Manager**: Declarative user environment management
- **Nix Darwin**: Declarative MacOS settings and program management
- **SOPS**: Encrypted secrets with private repository integration
- **Cachix**: Binary caching for faster rebuilds
