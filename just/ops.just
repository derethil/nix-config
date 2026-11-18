# Day-2 operations against the running homelab host (backups, podman containers)

[private]
default:
    @just --list ops

# Restic backup management and restoration
mod backups 'ops/backups.just'

# Homelab host (rootless podman) management recipes
mod homelab 'ops/homelab.just'
