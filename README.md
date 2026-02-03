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

## Features

Here's an overview of what my Nix configuration offers:

- **Multiple Compositors**: Heavily configured and opinionated Hyprland,
  Aerospace, and Niri configurations with unified options where possible

- **Desktop Shells**: A Dank Material Shell installation including various
  plugins to add QoL features and functionality like Outlook calendar
  integration,
  [Philips Hue management](https://github.com/derethil/dms-hue-manager/tree/main),
  and more

- **Gaming**: CachyOS kernel optimizations, low-latency audio configuration,
  modding tools, and a comprehensive launchers list including Steam,
  PrismLauncher, and Sober

- **Advanced Security and Impermanence**: BTRFS impermanence with root rollback,
  SOPS encrypted secret management, and LUKS full-disk encryption

- **Development**: My Neovim configuration is provided via a
  [custom flake](https://github.com/derethil/nvim-config) as well as my common
  DevEnv templates and a suite of useful developmental tools and utilities

- **Privacy-Hardened Browsing**: Firefox comes preconfigured with the addons I
  use as well as a host of privacy and security-focused configurations.

## Usage

```bash
git clone https://github.com/derethil/nix-config.git ~/.config/nix-config
cd ~/.config/nix-config
```

### Development Templates

```plaintext
# Node.js environment
github:derethil/nix-config#npm

# Node.js + Go environment
github:derethil/nix-config#dragonarmy-npm-golang

# Uv-managed Python environment
github:derethil/nix-config#python
```

## New Machine Installation

1. Create new system flake output with blank `hardware.nix` and modify
   `disko.nix` if necessary
1. Boot new machine with official NixOS ISO
1. Set password for nixos user using `passwd`
1. Connect the machine to the local network
1. Modify `disko` device path if necessary
1. Run the nixos-anywhere-install script with `nix run .#nixos-anywhere-install`
   and follow instructions

## System Architecture

### Hosts

- **Athena** (x86_64-linux): NixOS main desktop for day-to-day development and
  gaming
- **Hestia** (aarch64-darwin): Nix-Darwin managed macOS laptop

### Core Technologies

- **Snowfall Lib**: Modular configuration management with automatic imports
- **Home Manager**: Declarative user environment management
- **Nix Darwin**: Declarative MacOS settings and program management
- **SOPS**: Encrypted secrets with private repository integration
- **Cachix**: Binary caching for faster rebuilds
