set working-directory := ".."

[private]
default:
    @just --list flake

# Diff the last two system generations
diff:
    #!/usr/bin/env bash profiles=($(ls -dv /nix/var/nix/profiles/system-*-link | tail -2))
    dix "${profiles[0]}" "${profiles[1]}"

# Evaluate nix flake
check:
    nix flake check --all-systems

# Format with alejandra
format:
    alejandra $(fd .nix --exclude flake.nix)

# Prefetch a file and print its sha256 hash
get-hash url:
    nix store prefetch-file --hash-type sha256 {{ url }} 2>&1 | grep -oP "(?<=hash ')[^']+" | tr -d '[:space:]'

# Regenerate flake.nix and flake.lock from the current inputs
write:
    nix run .#write-flake && nix flake lock

# Update a flake input and commit the change to flake.lock (-a to amend the last commit)
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
