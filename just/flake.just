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
    nix formatter run $(fd .nix)

# Prefetch a file and print its sha256 hash
get-hash url:
    nix store prefetch-file --hash-type sha256 {{ url }} 2>&1 | grep -oP "(?<=hash ')[^']+" | tr -d '[:space:]'

# Regenerate flake.nix and flake.lock from the current inputs
write:
    nix run .#write-flake

# Visualize a NixOS or darwin host's module import graph (system + home-manager) in an interactive viewer
[arg("hostname", help="nixosConfigurations/darwinConfigurations name (default: current host)")]
graph hostname=`hostname`:
    #!/usr/bin/env bash
    set -euo pipefail
    if nix eval ".#nixosConfigurations.{{ hostname }}" --apply 'x: null' &>/dev/null; then
        darwinFlag=()
    elif nix eval ".#darwinConfigurations.{{ hostname }}" --apply 'x: null' &>/dev/null; then
        darwinFlag=(--darwin)
    else
        echo "error: '{{ hostname }}' is not a nixosConfigurations or darwinConfigurations output" >&2
        exit 1
    fi

    out="${XDG_CACHE_HOME:-$HOME/.cache}/nixoscope"
    mkdir -p "$out"

    tmp=$(mktemp -d)
    trap 'rm -rf "$tmp"' EXIT
    just eval {{ hostname }} graph "${darwinFlag[@]}" > "$tmp/0.json"

    users=$(just eval {{ hostname }} config.home-manager.users "${darwinFlag[@]}" --apply builtins.attrNames 2>/dev/null || echo '[]')

    i=1
    for user in $(echo "$users" | jq -r '.[]'); do
        homeExpr=".#homeConfigurations.\"${user}@{{ hostname }}\".graph"
        if nix eval "$homeExpr" --apply 'x: null' &>/dev/null; then
            nix eval --json "$homeExpr" > "$tmp/$i.json"
            i=$((i + 1))
        fi
    done

    cat "$tmp"/*.json | \
        jq -s '[{disabled: false, file: "/graph-root-source/flake.nix", key: "root", imports: add}]' | \
        nix run github:giomf/nixoscope -- --input /dev/stdin --format gv --option "flake.modules" > "$out/{{ hostname }}.gv"
    PYTHONWARNINGS="ignore::RuntimeWarning" nix run nixpkgs#xdot -- "$out/{{ hostname }}.gv"

# Update a flake input and commit the change to flake.lock (-a to amend the last commit)
[arg("amend", long="amend", short="a", value="true", help="Amend the last commit instead of creating a new one")]
update input amend="false":
    nix flake update {{ input }}
    @if ! git diff flake.lock --quiet; then \
        if [ "{{ amend }}" = "true" ]; then \
            git commit --amend --no-edit -- flake.lock; \
        else \
            git commit -m "chore(flake): update {{ input }} input" -- flake.lock; \
        fi; \
    fi
