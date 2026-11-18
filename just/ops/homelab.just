set working-directory := "../.."

homelab_user := "homelab"

[private]
default:
    @just --list ops homelab

# Run an arbitrary command as the homelab user (rootless podman host for all homelab containers)
[positional-arguments]
run *args:
    #!/usr/bin/env bash
    set -euo pipefail
    uid=$(id -u {{ homelab_user }})
    sudo runuser -u {{ homelab_user }} -- env HOME="/var/lib/{{ homelab_user }}" XDG_RUNTIME_DIR="/run/user/$uid" "$@"
