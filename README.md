<div align="center">

<h3>
  ❄️ derethil/nix-config
</h3>

<p>
    <a href="https://github.com/Doc-Steve/dendritic-design-with-flake-parts" target="_blank"><img alt="Design Dendritic" src="https://img.shields.io/static/v1?label=Design&message=Dendritic&color=5e81ac&style=for-the-badge"></a>&nbsp;<a href="https://github.com/derethil/nix-config"><img src="https://img.shields.io/github/last-commit/derethil/nix-config?style=for-the-badge&color=rgb(54%2C%2058%2C%2079)"></a>&nbsp;<a href="https://github.com/derethil/nix-config/actions/workflows/check-flake.yml" target="_blank"><img alt="Flake Check" src="https://img.shields.io/github/actions/workflow/status/derethil/nix-config/check-flake.yml?style=for-the-badge&label=flake%20check&color=a3be8c"></a>
</p>

</div>

# About

My configs for NixOS, MacOS, and Home Manager dotfiles. Uses flake-parts and the
[dendritic pattern](https://github.com/Doc-Steve/dendritic-design-with-flake-parts).

## Layout

- `hosts/` - per-machine entrypoints
- [`modules/`](./modules) - everything else, organized by topic
- `flake/` - internal flake plumbing
- `overlays/` - package overrides
- `templates/` - devenv templates (see below)

## Stuff I use

- **Compositors**: Niri and Paneru
- **Shell**: Dank Material Shell with my own
  [Hue manager plugin](https://github.com/derethil/dms-hue-manager/tree/main)
  and Outlook calendar integration
- **Development**: My [neovim flake](https://github.com/derethil/nvim-config),
  Claude Code w/ MCPs, AWS and Jira CLIs, Bruno
- **Gaming**: CachyOS kernel, low-latency audio, Steam, PrismLauncher, Sober,
  modding tools
- **Storage**: BTRFS impermanence with root rollback, LUKS, encrypted secrets
  pulled from my private repo

# Templates

`nix flake init -t github:derethil/nix-config#<name>`

- `npm` - pnpm + node, `dev` process pre-wired
- `python` - python 3.13 with `uv` and a venv
- `dragonarmy-npm-golang` - work template; go backend + node frontend with
  playwright, golangci-lint, and an AWS SSO pre-task
- `rust` - hello_world cargo project managed by `devenv`

# Installation

1. **Boot**: Boot the target machine using the minimal NixOS ISO and give root a
   password.
2. **Configure**: If provisioning a new host, create in `hosts/`, import modules
   as desired, and ensure it includes a `_disko.nix` configuration file.
   `_hardware.nix` will be generated automatically. If using LUKS disk
   encryption, set the new host's LUKS encryption key with `just secrets edit`.
3. **Bootstrap**: Run the following:

```bash
just bootstrap <hostname> <target-ip>
```
