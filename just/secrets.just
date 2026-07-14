set working-directory := ".."

sops_file := "secrets/secrets.yaml"
sops_config := ".sops.yaml"

[private]
default:
    @just --list secrets

[private]
get-path:
    @echo {{ sops_file }}

edit:
    sops {{ sops_file }}

# Add/update the age keys in the sops config
rekey:
    sops updatekeys {{ sops_file }}

# Commit any changes to the secrets submodule and the sops config (-p to also push)
update should_push="":
    #!/usr/bin/env bash
    set -euo pipefail

    if ! git -C secrets diff --quiet; then
        git -C secrets add secrets.yaml
        git -C secrets commit -m "chore(secrets): update secrets config"
    fi

    git add {{ sops_config }} secrets

    if ! git diff --cached --quiet; then
        git commit -m "chore(secrets): update secrets config"
    fi

    if [ "{{ should_push }}" = "-p" ]; then
        git push --recurse-submodules=on-demand
    fi

# Register an already-running host by fetching its existing SSH key
add-host hostname ip:
    #!/usr/bin/env bash
    set -euo pipefail
    age_key=$(ssh root@{{ ip }} "cat /etc/ssh/ssh_host_ed25519_key.pub" | nix run nixpkgs#ssh-to-age)
    just secrets _write-sops-key {{ hostname }} "$age_key"
    just secrets rekey
    just secrets update

# Copy personal age identity onto a machine so home-manager can decrypt secrets
provision-identity user ip:
    #!/usr/bin/env bash
    set -euo pipefail
    key="${SOPS_AGE_KEY_FILE:-$HOME/.config/sops/age/keys.txt}"

    if [[ ! -f "$key" ]]; then
        just print "{{ RED }}" "==> Error: No personal age key found at $key" >&2
        exit 1
    fi

    ctl=$(mktemp -u)
    trap 'ssh -o ControlPath="$ctl" -O exit {{ user }}@{{ ip }} 2>/dev/null || true' EXIT
    opts=(-o ControlMaster=auto -o ControlPath="$ctl" -o ControlPersist=60 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null)

    just print "{{ GREEN }}" "==> Provisioning age identity to {{ user }}@{{ ip }}..."
    ssh "${opts[@]}" {{ user }}@{{ ip }} 'install -d -m 700 "$HOME/.config/sops" "$HOME/.config/sops/age"'
    scp "${opts[@]}" "$key" {{ user }}@{{ ip }}:.config/sops/age/keys.txt
    ssh "${opts[@]}" {{ user }}@{{ ip }} 'chmod 600 "$HOME/.config/sops/age/keys.txt"'
    just print "{{ GREEN }}" "==> Successfully provisioned age identity."

# internal: print the age key to add, wait for manual edit
[private]
_write-sops-key hostname age_key:
    @just print "{{ YELLOW }}" "Add under 'keys:' in .sops.yaml:"
    @echo "  - &{{ hostname }} {{ age_key }}"
    @just print "{{ YELLOW }}" "And '*{{ hostname }}' to the relevant key_groups."
    @read -p "$(printf '\033[1;32mPress enter once .sops.yaml is updated...\033[0m')" _
