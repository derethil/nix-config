# ─── HELPER RECIPES ──────────────────────────────────────────────────────────

[private]
print color text:
    @echo -e "{{ color }}{{ text }}{{ NORMAL }}"

[private]
submodule-update:
    git submodule update --init --remote secrets

[private]
eval hostname path:
    @nix eval --json .#nixosConfigurations.{{ hostname }}.{{ path }} | jq -r '. // empty'

[private]
wait-for-host hostname ip:
    #!/usr/bin/env bash
    set -euo pipefail
    user=$(just eval {{ hostname }} config.internal.primaryUser)

    just print "{{ YELLOW }}" "==> Cleaning stale SSH host key entries for {{ ip }}..."
    ssh-keygen -R "{{ ip }}" >/dev/null 2>&1 || true
    ssh-keygen -R "{{ hostname }}" >/dev/null 2>&1 || true

    just print "{{ GREEN }}" "==> Waiting for {{ hostname }} ({{ ip }}) to accept SSH connections..."
    until ssh \
        -o ConnectTimeout=5 \
        -o StrictHostKeyChecking=no \
        -o UserKnownHostsFile=/dev/null \
        "$user@{{ ip }}" "true" 2>/dev/null; do
        sleep 5
        just print "{{ YELLOW }}" "    still waiting for {{ ip }}..."
    done
    just print "{{ GREEN }}" "==> Connection established!"

[private]
sync hostname ip:
    #!/usr/bin/env bash
    set -euo pipefail
    just submodule-update
    user=$(just eval {{ hostname }} config.internal.primaryUser)
    root=$(just eval {{ hostname }} config.internal.flakeRoot)
    just print "{{ GREEN }}" "==> Syncing flake to $root on {{ hostname }}..."
    ssh "$user@{{ ip }}" "mkdir -p $root"
    rsync -av --exclude='.git' ./ "$user@{{ ip }}:$root"

[private]
switch hostname ip:
    #!/usr/bin/env bash
    set -euo pipefail
    user=$(just eval {{ hostname }} config.internal.primaryUser)
    root=$(just eval {{ hostname }} config.internal.flakeRoot)
    just print "{{ GREEN }}" "==> Switching {{ hostname }} to its configuration..."
    ssh -t "$user@{{ ip }}" "sudo nixos-rebuild switch --flake '$root#{{ hostname }}'"

[private]
install hostname ip target_user="root":
    #!/usr/bin/env bash
    set -euo pipefail

    # ─── DEPS CHECK & AUTO-SHELL ─────────────────────────────────────────────

    if ! (command -v ssh-to-age &>/dev/null && command -v nixos-anywhere &>/dev/null); then
        just print "{{ YELLOW }}" "==> Required tools missing. Re-running inside a nix shell..."
        exec nix shell nixpkgs#ssh-to-age nixpkgs#nixos-anywhere nixpkgs#sops nixpkgs#age \
            --command bash -c 'just install "$1" "$2" "$3"' -- "{{ hostname }}" "{{ ip }}" "{{ target_user }}"
        exit 0
    fi

    # ─── SETUP ───────────────────────────────────────────────────────────────

    tmp=$(mktemp -d)
    trap 'rm -rf "$tmp"' EXIT

    just submodule-update

    # ─── LUKS ENCRYPTION ─────────────────────────────────────────────────────

    luks_device=$(just eval {{ hostname }} config.internal.boot.impermanence.luksDevice)
    sops_file=$(just secrets get-path)
    if [[ -n "$luks_device" ]]; then
        just print "{{ GREEN }}" "==> LUKS device '$luks_device' configured — extracting password..."
        sops -d --extract "[\"systems\"][\"{{ hostname }}\"][\"luksPassword\"]" "$sops_file" > "$tmp/luks-password.txt" \
            || { just print "{{ RED }}" "No systems.{{ hostname }}.luksPassword found in secrets.yaml" >&2; exit 1; }
        chmod 600 "$tmp/luks-password.txt"
        disk_encryption_flag=(--disk-encryption-keys /tmp/secret.key "$tmp/luks-password.txt")
    else
        just print "{{ YELLOW }}" "==> No LUKS device configured for {{ hostname }} — skipping disk encryption"
        disk_encryption_flag=()
    fi

    # ─── SSH HOST KEYS & SOPS RECIPIENT ──────────────────────────────────────

    just print "{{ GREEN }}" "==> Generating SSH host keys for {{ hostname }}..."
    ssh-keygen -t ed25519 -f "$tmp/ssh_host_ed25519_key" -N "" -C "root@{{ hostname }}"
    ssh-keygen -t rsa -b 4096 -f "$tmp/ssh_host_rsa_key" -N "" -C "root@{{ hostname }}"

    ssh-to-age -private-key -i "$tmp/ssh_host_ed25519_key" -o "$tmp/age_key.txt"
    age_key=$(age-keygen -y "$tmp/age_key.txt")
    echo "    age key: $age_key"

    just print "{{ GREEN }}" "==> Registering {{ hostname }} as a sops recipient..."
    just secrets _write-sops-key {{ hostname }} "$age_key"
    just secrets rekey
    just secrets update -p

    # ─── HARDWARE.NIX GENERATION ─────────────────────────────────────────────

    hw_file="hosts/{{ hostname }}/_hardware.nix"
    hw_flag=()
    if [[ ! -f "$hw_file" ]]; then
        just print "{{ YELLOW }}" "==> No $hw_file found — will generate from target hardware"
        hw_flag=(--generate-hardware-config nixos-generate-config "$hw_file")
    fi

    # ─── PATH RESOLUTION FOR IMPERMANENCE ────────────────────────────────────

    impermanence_enabled=$(just eval {{ hostname }} config.internal.boot.impermanence.enabled)
    if [[ "$impermanence_enabled" == "true" ]]; then
        just print "{{ GREEN }}" "==> Impermanence detected. Writing keys to persistent volume path..."
        persist_prefix="/persist"
    else
        just print "{{ YELLOW }}" "==> Impermanence disabled. Writing keys to standard path..."
        persist_prefix=""
    fi

    # ─── EXTRA FILES ─────────────────────────────────────────────────────────

    just print "{{ GREEN }}" "==> Preparing extra-files..."
    install -d -m 755 "$tmp/extra-files${persist_prefix}/etc/ssh"
    install -m 600 "$tmp/ssh_host_ed25519_key" "$tmp/extra-files${persist_prefix}/etc/ssh/ssh_host_ed25519_key"
    install -m 644 "$tmp/ssh_host_ed25519_key.pub" "$tmp/extra-files${persist_prefix}/etc/ssh/ssh_host_ed25519_key.pub"
    install -m 600 "$tmp/ssh_host_rsa_key" "$tmp/extra-files${persist_prefix}/etc/ssh/ssh_host_rsa_key"
    install -m 644 "$tmp/ssh_host_rsa_key.pub" "$tmp/extra-files${persist_prefix}/etc/ssh/ssh_host_rsa_key.pub"

    install -d -m 755 "$tmp/extra-files${persist_prefix}/etc/sops/age"
    install -m 600 "$tmp/age_key.txt" "$tmp/extra-files${persist_prefix}/etc/sops/age/keys.txt"

    # ─── CONFIRMATION & INSTALL ───────────────────────────────────────────────

    just print "{{ RED }}" "This will WIPE the disk on {{ hostname }} ({{ ip }}). Continue? [y/N]"
    read -r confirm
    [[ "$confirm" =~ ^[Yy]$ ]] || { just print "{{ YELLOW }}" "Cancelled."; exit 1; }

    nixos-anywhere \
        --flake '.#{{ hostname }}' \
        --target-host {{ target_user }}@{{ ip }} \
        "${disk_encryption_flag[@]}" \
        "${hw_flag[@]}" \
        --extra-files "$tmp/extra-files" \
        --build-on local

    if [[ ${#hw_flag[@]} -gt 0 ]]; then
        just print "{{ GREEN }}" "==> Committing generated hardware config..."
        git add "$hw_file"
        git commit -m "feat(hosts): add hardware config for {{ hostname }}"
    fi

# Bootstrap a new host by installing NixOS, waiting for it to come online, and deploying the flake
bootstrap hostname ip target_user="root":
    just install {{ hostname }} {{ ip }} {{ target_user }}
    just wait-for-host {{ hostname }} {{ ip }}

    just secrets provision-identity $(just eval {{ hostname }} config.internal.primaryUser) {{ ip }}

    just sync {{ hostname }} {{ ip }}
    just switch {{ hostname }} {{ ip }}
