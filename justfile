# Path to the old (snowfall) worktree, used as the diff reference
# during the dendritic migration. See dendritic-migration.md.

old := "../nix-config"

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

# --- dendritic migration recipes ---------------------------------------
# Diff the old (snowfall) build against the new (dendritic) build for a
# given target. Empty output = byte-identical closures. See
# dendritic-migration.md for the full workflow.

# Build both old and new NixOS host configs, then nvd diff them.
diff-system host:
    nix build {{ old }}#nixosConfigurations.{{ host }}.config.system.build.toplevel -o result-old
    nix build .#nixosConfigurations.{{ host }}.config.system.build.toplevel -o result-new
    nvd diff result-old result-new

# Same for a home-manager target (e.g. derethil@gaia).
diff-home target:
    nix build {{ old }}#homeConfigurations."{{ target }}".activationPackage -o result-old
    nix build .#homeConfigurations."{{ target }}".activationPackage -o result-new
    nvd diff result-old result-new

# Closure-level diff (faster, less detail than nvd).
diff-closures host:
    nix store diff-closures \
        $(nix path-info {{ old }}#nixosConfigurations.{{ host }}.config.system.build.toplevel) \
        $(nix path-info .#nixosConfigurations.{{ host }}.config.system.build.toplevel)

# Derivation-input diff — use when nvd reports changes but you can't

# tell where they came from.
diff-drv host:
    nix-diff \
        $(nix path-info --derivation {{ old }}#nixosConfigurations.{{ host }}.config.system.build.toplevel) \
        $(nix path-info --derivation .#nixosConfigurations.{{ host }}.config.system.build.toplevel)

# Remove the result-* symlinks left behind by the diff recipes.
diff-clean:
    rm -f result-old result-new
