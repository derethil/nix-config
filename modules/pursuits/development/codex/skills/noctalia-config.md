---
name: noctalia-config
description: Update Derethil's declarative Noctalia shell and plugin configuration when changing Noctalia settings, layout, widgets, or plugins.
---

Manage the Noctalia configuration at `/home/derethil/.config/nix-config` as an immutable Home Manager configuration.

## Sources of truth

- `modules/surfaces/lib/panel/noctalia/settings.nix` holds the full Noctalia configuration: both non-default choices and explicit defaults.
- `modules/surfaces/lib/panel/noctalia/plugins.nix` holds the enabled-plugin list, plugin-wide settings, and Nix package dependencies.
- `modules/surfaces/lib/panel/noctalia/default.nix` clears Noctalia's GUI state file on Home Manager activation. Do not restore an out-of-store symlink or make the state file persistent.

The generated `~/.config/noctalia/config.toml` is immutable. Settings UI changes are runtime overrides in `~/.local/state/noctalia/settings.toml`; they are intentionally discarded at the next Home Manager activation unless ported into the Nix files.

## Updating after UI changes

When asked to bring current UI changes into Nix:

1. Read `~/.local/state/noctalia/settings.toml` and export defaults with `noctalia config export full`.
2. Merge the state TOML recursively over the full export before converting it. In the current Noctalia release, the full exporter can omit some state overrides.
3. Regenerate `settings.nix` from that merged data, excluding `plugins` and `plugin_settings`.
4. Move `plugins` and `plugin_settings` into `plugins.nix`. Retain Nix dependencies there as well.
5. Prefer bare Nix attribute names. Quote only keys invalid in Nix syntax, such as IDs containing `@` or `/`.
6. Run `just flake format` afterwards. Do not activate the configuration or restart Noctalia unless the user asks.

Plugin source code and updates are managed by Noctalia; Nix declaratively controls which plugins are enabled and their settings.
