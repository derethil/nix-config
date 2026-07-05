default:
    @just --list

update input amend='':
    nix flake update {{ input }}
    git add flake.lock
    @if ! git diff --cached --quiet flake.lock; then \
        if [ "{{ amend }}" = "-a" ]; then \
            git commit --amend --no-edit; \
        else \
            git commit -m "chore(flake): update {{ input }} input"; \
        fi; \
    fi

diff:
    #!/usr/bin/env bash
    profiles=($(ls -dv /nix/var/nix/profiles/system-*-link | tail -2))
    dix "${profiles[0]}" "${profiles[1]}"

check:
    nix flake check --all-systems

format:
    alejandra $(fd .nix --exclude flake.nix)

get-hash url:
    nix store prefetch-file --hash-type sha256 {{ url }} 2>&1 | grep -oP "(?<=hash ')[^']+" | tr -d '[:space:]'

secrets:
    #!/usr/bin/env bash
    SECRETS_DIR="${SECRETS_DIR:-$HOME/.config/nix-secrets}"
    CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/nix-config}"

    cd "$SECRETS_DIR"
    sops secrets.yaml
    git add secrets.yaml

    if ! git diff --cached --quiet; then
        git commit -m "chore: update secrets"
        git push
    fi


    cd "$CONFIG_DIR"
    @just update secrets

uflake:
    nix run .#write-flake && nix flake lock

dms-settings:
    #!/usr/bin/env bash
    set -euo pipefail
    OLD_REV=$(git show HEAD~1:flake.lock | jq -r '.nodes["dank-material-shell"].locked.rev')
    NEW_REV=$(jq -r '.nodes["dank-material-shell"].locked.rev' flake.lock)
    if [ "$OLD_REV" = "$NEW_REV" ]; then
        echo "No change in dank-material-shell"
        exit 0
    fi
    BASE="https://raw.githubusercontent.com/AvengeMedia/DankMaterialShell"
    diff -u \
        <(curl -sf "$BASE/$OLD_REV/quickshell/Common/settings/SettingsSpec.js") \
        <(curl -sf "$BASE/$NEW_REV/quickshell/Common/settings/SettingsSpec.js") \
        | diff-so-fancy || true
