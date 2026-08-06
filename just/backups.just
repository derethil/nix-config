set working-directory := ".."

env_file := "/run/secrets/rendered/restic-env"
repo_file := "/run/secrets/services/restic/repository"
pass_file := "/run/secrets/services/restic/repository_password"
services := `systemctl list-unit-files 'restic-backups-*.service' --no-legend | awk '{print $1}' | sed 's/^restic-backups-//; s/\.service$//' | sort | xargs`

[private]
_load_env := "set -a; source <(sudo cat " + env_file + "); set +a; export RESTIC_REPOSITORY=$(sudo cat " + repo_file + "); export RESTIC_PASSWORD=$(sudo cat " + pass_file + "); export RESTIC_CACHE_DIR=$HOME/.cache/restic"

[private]
default:
    @just --list backups

# List all snapshots in the repository
[arg("tag", help="Only show snapshots with this tag (e.g. paperless)")]
snapshots tag="":
    #!/usr/bin/env bash
    set -euo pipefail
    {{ _load_env }}
    tag="{{ tag }}"
    restic snapshots --group-by tags ${tag:+--tag "$tag"}

# Show repository disk usage and stats
stats:
    #!/usr/bin/env bash
    set -euo pipefail
    {{ _load_env }}
    restic stats

# List files in a snapshot
[arg("snapshot", help="Snapshot ID, or a service tag to list its latest (default: latest)")]
[arg("tag", help="Only consider snapshots with this tag (e.g. paperless)")]
ls snapshot="latest" tag="":
    #!/usr/bin/env bash
    set -euo pipefail
    {{ _load_env }}
    snapshot="{{ snapshot }}"
    tag="{{ tag }}"
    # If the only arg is a known service, treat it as a tag against the latest snapshot.
    if [ -z "$tag" ] && printf '%s\n' {{ services }} | grep -qx "$snapshot"; then
        tag="$snapshot"
        snapshot="latest"
    fi
    restic ls "$snapshot" ${tag:+--tag "$tag"}

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
_check-service service:
    #!/usr/bin/env bash
    case "{{ service }}" in
        all|{{ replace(services, " ", "|") }}) ;;
        *) echo "unknown service: {{ service }}"; exit 1 ;;
    esac

# Restore a service from a snapshot
[arg("service", help="Service to restore (or all)")]
[arg("snapshot", help="Snapshot ID to restore from (default: latest)")]
restore service="all" snapshot="latest": (_check-service service)
    #!/usr/bin/env bash
    set -euo pipefail
    if [ "{{ service }}" = "all" ]; then
        for svc in {{ services }}; do
            restic-restore-$svc "{{ snapshot }}"
        done
    else
        restic-restore-{{ service }} "{{ snapshot }}"
    fi

# Trigger a manual backup (or all)
[arg("service", help="Service to backup (or all)")]
backup service="all": (_check-service service)
    #!/usr/bin/env bash
    set -uo pipefail
    status=0
    backup_one() {
        just print "{{ YELLOW }}" "==> Backing up $1..."
        if sudo systemctl start "restic-backups-$1.service"; then
            just print "{{ GREEN }}" "==> Done."
        else
            just print "{{ RED }}" "==> Failed: $1 (see: journalctl -u restic-backups-$1)"
            status=1
        fi
    }
    if [ "{{ service }}" = "all" ]; then
        for svc in {{ services }}; do backup_one "$svc"; done
    else
        backup_one "{{ service }}"
    fi
    exit $status

# Run the full nightly job now: all backups in sequence, then prune + check once
nightly:
    #!/usr/bin/env bash
    set -euo pipefail
    just print "{{ YELLOW }}" "==> Running nightly backup + maintenance (watch: journalctl -fu restic-nightly)..."
    sudo systemctl start restic-nightly.service
    just print "{{ GREEN }}" "==> Done."

# Show backup service status
[arg("service", help="Service to check status for (or all)")]
status service="all": (_check-service service)
    #!/usr/bin/env bash
    set -euo pipefail
    if [ "{{ service }}" = "all" ]; then
        for svc in {{ services }}; do
            just print "{{ YELLOW }}" "==> Checking status of $svc..."
            sudo systemctl status "restic-backups-$svc.service" || true
        done
    else
        just print "{{ YELLOW }}" "==> Checking status of {{ service }}..."
        sudo systemctl status "restic-backups-{{ service }}.service" || true
    fi
