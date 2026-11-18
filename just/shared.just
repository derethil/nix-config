# ─── SHARED HELPERS ──────────────────────────────────────────────────────────
# Imported (not mod-ed) at the top level so every other module can call these
# unprefixed, e.g. `just print ...`, `just eval ...`.

[private]
print color text:
    @echo -e "{{ color }}{{ text }}{{ NORMAL }}"

[private]
submodule-update:
    git submodule update --init --remote secrets

[arg("hostname", help="nixosConfigurations/darwinConfigurations name")]
[arg("path", help="path to evaluate (e.g. config.internal.primaryUser)")]
[arg("darwin", long="darwin", value="true", help="treat the hostname as a darwinConfigurations output instead of nixosConfigurations")]
[arg("apply", long="apply", help="nix function to post-process the evaluated value (e.g. builtins.attrNames)")]
[private]
eval hostname path darwin="false" apply="x: x":
    #!/usr/bin/env bash
    set -euo pipefail
    if [ "{{ darwin }}" = "true" ]; then
        nix eval --json ".#darwinConfigurations.{{ hostname }}.{{ path }}" --apply '{{ apply }}' | jq -r '. // empty'
    else
        nix eval --json ".#nixosConfigurations.{{ hostname }}.{{ path }}" --apply '{{ apply }}' | jq -r '. // empty'
    fi
