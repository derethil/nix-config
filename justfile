# Shared print/eval helpers available unprefixed to every recipe below
import 'just/shared.just'

# Host provisioning: new installs, identity/secret enrollment
mod provision 'just/provision.just'

# Day-2 operations against the running homelab host (backups, podman containers)
mod ops 'just/ops.just'

# Secrets management recipes
mod secrets 'just/secrets.just'

# Repo/dev tooling (flake, lint, renovate) — never touches a live host
mod repo 'just/repo.just'

# Darwin (macOS) maintenance recipes
mod darwin 'just/darwin.just'

[private]
default:
    @just --list
