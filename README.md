<div align="center">

<h3>
  ❄️ derethil/nix-config
</h3>

<p>
    <a href="https://github.com/Doc-Steve/dendritic-design-with-flake-parts" target="_blank"><img alt="Design Dendritic" src="https://img.shields.io/static/v1?label=Design&message=Dendritic&color=5e81ac&style=for-the-badge"></a>&nbsp;<a href="https://github.com/derethil/nix-config"><img src="https://img.shields.io/github/last-commit/derethil/nix-config?style=for-the-badge&color=rgb(54%2C%2058%2C%2079)"></a>&nbsp;<a href="https://github.com/derethil/nix-config/actions/workflows/cachix.yml" target="_blank"><img alt="Build" src="https://img.shields.io/github/actions/workflow/status/derethil/nix-config/cache-build.yml?style=for-the-badge&label=build"></a>
</p>

</div>

# About

My configs for NixOS, MacOS, and Home Manager dotfiles. I use flake-parts and
the
[dendritic pattern](https://github.com/Doc-Steve/dendritic-design-with-flake-parts)
to manage my development/gaming machine, laptop, and a self-hosted server.

## Layout

- `hosts/` - per-machine entrypoints
- [`modules/`](./modules) - everything else, organized by topic
- `flake/` - internal flake plumbing
- `overlays/` - package overrides
- `templates/` - devenv templates (see below)

## Stuff I use

- **Compositors**: Niri and Paneru
- **Shell**: ( Noctalia v5)[https://noctalia.dev/] with calendar event
  integration via khal, vdirsyncer, and davmail
- **Development**: My [neovim flake](https://github.com/derethil/nvim-config),
  Claude Code w/ MCPs, AWS and Jira CLIs, Bruno
- **Gaming**: CachyOS kernel, low-latency audio, Steam, PrismLauncher, Sober,
  modding tools
- **Storage**: BTRFS impermanence with root rollback, LUKS, encrypted secrets
  pulled from my private repo
- **Self-hosting**: Rootless Podman containers integrated with fully declarative
  restic backup/restore and caddy modules, Gatus dashboard, and ntfy-backed
  notification system

# Task Runner

Common operations are managed via [`just`](https://github.com/casey/just). Run
`just` at the repo root to see all available commands, organized into
subcommands. Everything from rebuilding to secret management to backup
restoration to linting has a recipe.

# Development Environments

I use `devenv` to manage my environments. Each of these templates supply project
management or development tooling for a specific language. Copy one into a
project with:

`nix flake init -t github:derethil/nix-config#<name>`

- `fullstack-node-go` - tooling for golang+node projects with AWS SSO
  authentication
- `node` - standalone Node.js tooling managed via `pnpm`
- `python` - `uv` based python environment
- `rust` - a `hello_world` Cargo project

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
