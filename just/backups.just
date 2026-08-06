set working-directory := ".."

env_file := "/run/secrets/rendered/restic-env"
repo_file := "/run/secrets/services/homelab/restic/repository"
pass_file := "/run/secrets/services/homelab/restic/repository_password"
staging := "/var/lib/restic/staging"
volumes := "/var/lib/containers/storage/volumes"

services := "healthchecks tandoor blombooru paperless"

[private]
_load_env := "set -a; eval \"$(sudo cat " + env_file + ")\"; set +a; export RESTIC_REPOSITORY=$(sudo cat " + repo_file + "); export RESTIC_PASSWORD=$(sudo cat " + pass_file + "); export RESTIC_CACHE_DIR=$HOME/.cache/restic"

[private]
default:
    @just --list backups

# List all snapshots in the repository
snapshots:
    #!/usr/bin/env bash
    set -euo pipefail
    {{ _load_env }}
    restic snapshots --group-by tags

# Show repository disk usage and stats
stats:
    #!/usr/bin/env bash
    set -euo pipefail
    {{ _load_env }}
    restic stats

# List files in a snapshot
[arg("snapshot", help="Snapshot ID or tag to list (default: latest)")]
ls snapshot="latest":
    #!/usr/bin/env bash
    set -euo pipefail
    {{ _load_env }}
    restic ls {{ snapshot }}

# Unlock a stuck/interrupted repository
unlock:
    #!/usr/bin/env bash
    set -euo pipefail
    {{ _load_env }}
    restic unlock

# Run an arbitrary restic command against the configured repository
[positional-arguments]
run *args:
    #!/usr/bin/env bash
    set -euo pipefail
    {{ _load_env }}
    restic "$@"

[private]
_pg-restore container user database dump:
    #!/usr/bin/env bash
    set -euo pipefail
    just print "{{ YELLOW }}" "==> Waiting for postgres..."
    until timeout 2 sudo podman exec {{ container }} pg_isready -U {{ user }} &>/dev/null; do sleep 1; done
    just print "{{ YELLOW }}" "==> Restoring database..."
    sudo podman exec -i {{ container }} pg_restore -U {{ user }} -d {{ database }} --clean --if-exists \
        < "{{ dump }}"

# Restore healthchecks data from a snapshot
[arg("snapshot", help="Snapshot ID to restore from (default: latest)")]
restore-healthchecks snapshot="latest":
    #!/usr/bin/env bash
    set -euo pipefail
    {{ _load_env }}
    tmp=$(mktemp -d)
    trap 'rm -rf "$tmp"' EXIT

    just print "{{ YELLOW }}" "==> Stopping healthchecks..."
    sudo systemctl stop healthchecks.service

    just print "{{ YELLOW }}" "==> Restoring {{ snapshot }}..."
    restic restore {{ snapshot }} \
        --path "{{ volumes }}/healthchecks-data/_data" \
        --include "{{ volumes }}/healthchecks-data" \
        --target "$tmp"

    just print "{{ YELLOW }}" "==> Syncing volume..."
    sudo rsync -a --delete "$tmp/{{ volumes }}/healthchecks-data/_data/" \
        "{{ volumes }}/healthchecks-data/_data/"

    just print "{{ YELLOW }}" "==> Starting healthchecks..."
    sudo systemctl start healthchecks.service
    just print "{{ GREEN }}" "==> Done."

# Restore tandoor from a snapshot (media + postgres)
[arg("snapshot", help="Snapshot ID to restore from (default: latest)")]
restore-tandoor snapshot="latest":
    #!/usr/bin/env bash
    set -euo pipefail
    {{ _load_env }}
    tmp=$(mktemp -d)
    trap 'rm -rf "$tmp"' EXIT

    just print "{{ YELLOW }}" "==> Stopping tandoor..."
    sudo systemctl stop tandoor-web.service tandoor-db.service tandoor-pod.service

    just print "{{ YELLOW }}" "==> Restoring {{ snapshot }}..."
    restic restore {{ snapshot }} \
        --path "{{ volumes }}/tandoor-media/_data" \
        --include "{{ volumes }}/tandoor-media" \
        --include "{{ staging }}/tandoor" \
        --target "$tmp"

    just print "{{ YELLOW }}" "==> Syncing media volume..."
    sudo rsync -a --delete "$tmp/{{ volumes }}/tandoor-media/_data/" \
        "{{ volumes }}/tandoor-media/_data/"

    sudo systemctl start tandoor-pod.service tandoor-db.service
    just backups _pg-restore tandoor-db djangodb djangodb "$tmp/{{ staging }}/tandoor/tandoor-db-djangodb.dump"

    just print "{{ YELLOW }}" "==> Starting tandoor..."
    sudo systemctl start tandoor-web.service
    just print "{{ GREEN }}" "==> Done."

# Restore blombooru from a snapshot (data + media + postgres)
[arg("snapshot", help="Snapshot ID to restore from (default: latest)")]
restore-blombooru snapshot="latest":
    #!/usr/bin/env bash
    set -euo pipefail
    {{ _load_env }}
    tmp=$(mktemp -d)
    trap 'rm -rf "$tmp"' EXIT

    just print "{{ YELLOW }}" "==> Stopping blombooru..."
    sudo systemctl stop blombooru-web.service blombooru-redis.service \
        blombooru-db.service blombooru-pod.service

    just print "{{ YELLOW }}" "==> Restoring {{ snapshot }}..."
    restic restore {{ snapshot }} \
        --path "{{ volumes }}/blombooru-data/_data" \
        --include "{{ volumes }}/blombooru-data" \
        --include "{{ volumes }}/blombooru-media" \
        --include "{{ staging }}/blombooru" \
        --target "$tmp"

    just print "{{ YELLOW }}" "==> Syncing data volumes..."
    sudo rsync -a --delete "$tmp/{{ volumes }}/blombooru-data/_data/" \
        "{{ volumes }}/blombooru-data/_data/"
    sudo rsync -a --delete "$tmp/{{ volumes }}/blombooru-media/_data/" \
        "{{ volumes }}/blombooru-media/_data/"

    sudo systemctl start blombooru-pod.service blombooru-db.service
    just backups _pg-restore blombooru-db blombooru blombooru "$tmp/{{ staging }}/blombooru/blombooru-db-blombooru.dump"

    just print "{{ YELLOW }}" "==> Starting blombooru..."
    sudo systemctl start blombooru-redis.service blombooru-web.service
    just print "{{ GREEN }}" "==> Done."

# Restore paperless from a snapshot (data + media + consume + postgres)
[arg("snapshot", help="Snapshot ID to restore from (default: latest)")]
restore-paperless snapshot="latest":
    #!/usr/bin/env bash
    set -euo pipefail
    {{ _load_env }}
    tmp=$(mktemp -d)
    trap 'rm -rf "$tmp"' EXIT

    just print "{{ YELLOW }}" "==> Stopping paperless..."
    sudo systemctl stop paperless-web.service paperless-broker.service \
        paperless-db.service paperless-pod.service

    just print "{{ YELLOW }}" "==> Restoring {{ snapshot }}..."
    restic restore {{ snapshot }} \
        --path "{{ volumes }}/paperless-data/_data" \
        --include "{{ volumes }}/paperless-data" \
        --include "{{ volumes }}/paperless-media" \
        --include "{{ volumes }}/paperless-consume" \
        --include "{{ staging }}/paperless" \
        --target "$tmp"

    just print "{{ YELLOW }}" "==> Syncing data volumes..."
    sudo rsync -a --delete "$tmp/{{ volumes }}/paperless-data/_data/" \
        "{{ volumes }}/paperless-data/_data/"
    sudo rsync -a --delete "$tmp/{{ volumes }}/paperless-media/_data/" \
        "{{ volumes }}/paperless-media/_data/"
    sudo rsync -a --delete "$tmp/{{ volumes }}/paperless-consume/_data/" \
        "{{ volumes }}/paperless-consume/_data/"

    sudo systemctl start paperless-pod.service paperless-db.service
    just backups _pg-restore paperless-db paperless paperless "$tmp/{{ staging }}/paperless/paperless-db-paperless.dump"

    just print "{{ YELLOW }}" "==> Starting paperless..."
    sudo systemctl start paperless-broker.service paperless-web.service
    just print "{{ GREEN }}" "==> Done."

# Restore all services from a snapshot
[arg("snapshot", help="Snapshot ID to restore from (default: latest)")]
restore-all snapshot="latest":
    #!/usr/bin/env bash
    for svc in {{ services }}; do
        just backups restore-$svc {{ snapshot }}
    done

# Trigger a manual backup (or all)
[arg("service", pattern='^(all|healthchecks|tandoor|blombooru|paperless)$', help="Service to backup (or all)")]
backup service="all":
    #!/usr/bin/env bash
    set -euo pipefail
    if [ "{{ service }}" = "all" ]; then
        for svc in {{ services }}; do
            just print "{{ YELLOW }}" "==> Backing up $svc..."
            sudo systemctl start "restic-backups-$svc.service"
            just print "{{ GREEN }}" "==> Done."
        done
    else
        just print "{{ YELLOW }}" "==> Backing up {{ service }}..."
        sudo systemctl start "restic-backups-{{ service }}.service"
        just print "{{ GREEN }}" "==> Done."
    fi

[arg("service", pattern='^(all|healthchecks|tandoor|blombooru|paperless)$', help="Service to check status for (or all)")]
status service="all":
    #!/usr/bin/env bash
    set -euo pipefail
    if [ "{{ service }}" = "all" ]; then
        for svc in {{ services }}; do
            just print "{{ YELLOW }}" "==> Checking status of $svc..."
            sudo systemctl status "restic-backups-$svc.service"
        done
    else
        just print "{{ YELLOW }}" "==> Checking status of {{ service }}..."
        sudo systemctl status "restic-backups-{{ service }}.service"
    fi
