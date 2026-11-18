set working-directory := ".."

sops_file := "secrets/secrets.yaml"
sops_config := ".sops.yaml"

[private]
default:
    @just --list secrets

[private]
get-path:
    @echo {{ sops_file }}

# Edit secrets, then automatically validate them for a host
[arg("hostname", help="Host to validate after editing (default: feldspar)")]
edit hostname="feldspar":
    #!/usr/bin/env bash
    set -euo pipefail
    sops {{ sops_file }}
    just secrets update -p
    just secrets check {{ hostname }}

# Decrypt a single secret and copy its value to the clipboard
[arg("path", help="Secret path in a/b/c form, matching the nix config.sops.secrets key (e.g. serve/bookorbit/jwt_secret)")]
copy path:
    #!/usr/bin/env bash
    set -euo pipefail
    query=$(printf '%s' "{{ path }}" | awk -F/ '{for (i = 1; i <= NF; i++) printf "[\"%s\"]", $i}')
    sops -d --extract "$query" {{ sops_file }} | wl-copy
    just print "{{ GREEN }}" "==> Copied {{ path }} to clipboard."

# Add/update the age keys in the sops config
rekey:
    sops updatekeys {{ sops_file }}

# Validate every secret for a host decrypts and renders, without touching the system
[arg("hostname", help="NixOS configuration to validate (default: feldspar)")]
check hostname="feldspar":
    #!/usr/bin/env bash
    set -euo pipefail

    just print "{{ GREEN }}" "==> Building {{ hostname }} to locate its sops manifests..."
    toplevel=$(nix build --no-link --print-out-paths ".#nixosConfigurations.{{ hostname }}.config.system.build.toplevel")

    sops_bin=$(grep -m1 -oE "/nix/store/[a-z0-9]+-sops-install-secrets[^ ]*/bin/sops-install-secrets" "$toplevel/activate" || true)
    if [[ -z "$sops_bin" ]]; then
        just print "{{ YELLOW }}" "==> No sops secrets configured for {{ hostname }} — nothing to check."
        exit 0
    fi

    mapfile -t manifests < <(grep -oE "/nix/store/[a-z0-9]+-manifest(-for-users)?\.json" "$toplevel/activate" | sort -u)

    rc=0
    for manifest in "${manifests[@]}"; do
        if "$sops_bin" -check-mode=manifest "$manifest" >/dev/null 2>&1; then
            just print "{{ GREEN }}" "==> OK   $(basename "$manifest")"
        else
            just print "{{ RED }}" "==> FAIL $(basename "$manifest")"
            "$sops_bin" -check-mode=manifest "$manifest" || true
            rc=1
        fi
    done

    if [[ "$rc" -eq 0 ]]; then
        just print "{{ GREEN }}" "==> All secrets decrypt and render cleanly for {{ hostname }}."
    else
        just print "{{ RED }}" "==> Secret validation FAILED — do not activate {{ hostname }}."
    fi
    exit "$rc"

# Commit any changes to the secrets submodule and the sops config
[arg("should_push", long="push", short="p", value="true", help="Push commits after updating")]
update should_push="false":
    #!/usr/bin/env bash
    set -euo pipefail

    # Stash the currently staged changes (as a patch, so partial hunks from
    # `git add -p` survive) so the secrets commit stays isolated, then
    # re-apply them once we're done.
    staged_patch=$(mktemp)
    trap 'rm -f "$staged_patch"' EXIT
    git diff --cached > "$staged_patch"
    git reset -q

    if ! git -C secrets diff --quiet; then
        git -C secrets add secrets.yaml
        git -C secrets commit -m "chore(secrets): update secrets config"
    fi

    git add {{ sops_config }} secrets

    if ! git diff --cached --quiet; then
        git commit -m "chore(secrets): update secrets config"
    fi

    if [ -s "$staged_patch" ]; then
        git apply --cached "$staged_patch"
    fi

    if [ "{{ should_push }}" = "true" ]; then
        git -C secrets push
    fi
