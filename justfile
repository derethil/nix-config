default:
    @just --list

update input:
    nix flake update {{ input }}
    git add flake.lock
    git diff --cached --quiet flake.lock || git commit -m "chore(flake): update {{ input }} input"

check:
    nix flake check --all-systems

format:
    alejandra $(fd .nix)

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
