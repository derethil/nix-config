# `modules`

Contains all my configuration outputs. Hosts, templates, overlays, and flake
plumbing are root-lvel.

## Layout

- [`apps/`](./apps): user-facing applications
- `bridges/`: platform specific integrations
- `foundation/`: nix, shell, system, and user config for every host
- `homelab/`: self-hosted server stack
- `machine/`: boot, kernel, and hardware configuration
- `services/`: background daemons not tied to specific hardware
- `surfaces/`: desktop and UI layers
