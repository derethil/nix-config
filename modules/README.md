# `modules`

Contains all my configuration outputs. Hosts, templates, overlays, and flake
plumbing live at the root.

## Layout

- `foundation/`: baseline module that every host imports
- `machine/`: hardware-adjacent services and boot/kernel stuff
- `surfaces/`: desktop and UI layers
- `pursuits/`: user-facing applications
- `bridges/`: platform specific integrations
- `hosting/`: self-hosted external services
- `services/`: system daemons and background services
