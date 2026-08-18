set working-directory := ".."

[private]
default:
    @just --list darwin

# Reset TCC categories with stale nix store paths
[arg("service", help="TCC service to clean, e.g. kTCCServiceAccessibility, kTCCServiceCamera (default: every service)")]
cleanup-privacy service="all":
    #!/usr/bin/env bash
    set -euo pipefail

    if [[ "{{ service }}" == "all" ]]; then
        where=""
    else
        where="WHERE service = '{{ service }}'"
    fi

    stale_desc=()
    stale_services=()

    check_db() {
        local db="$1" sudo_cmd="$2"
        local rows
        rows=$($sudo_cmd sqlite3 -separator $'\t' "$db" \
            "SELECT service, client, client_type FROM access $where;" 2>&1) || {
            just print "{{ RED }}" "==> Failed to read $db: $rows"
            just print "{{ YELLOW }}" "    Grant Full Disk Access to your terminal app in System Settings > Privacy & Security > Full Disk Access, then retry."
            exit 1
        }
        [[ -z "$rows" ]] && return
        while IFS=$'\t' read -r svc client client_type; do
            [[ -z "$svc" ]] && continue
            [[ "$client_type" != "1" ]] && continue
            [[ -e "$client" ]] && continue
            stale_desc+=("$svc  $client")
            stale_services+=("$svc")
        done <<< "$rows"
    }

    check_db "$HOME/Library/Application Support/com.apple.TCC/TCC.db" ""
    just print "{{ YELLOW }}" "==> Checking system TCC db (needs sudo)"
    check_db "/Library/Application Support/com.apple.TCC/TCC.db" "sudo"

    just print "{{ YELLOW }}" "==> Not in TCC.db, clean manually in System Settings:"
    printf '    %s\n' \
        "Location Services" \
        "Local Network" \
        "Passkeys Access for Web Browsers" \
        "Home" \
        "Remote Desktop" \
        "Motion & Fitness" \
        "Speech Recognition"

    if [[ ${#stale_desc[@]} -eq 0 ]]; then
        just print "{{ GREEN }}" "==> No stale entries found."
        exit 0
    fi

    just print "{{ YELLOW }}" "==> Found ${#stale_desc[@]} stale entries:"
    printf '    %s\n' "${stale_desc[@]}" | sort

    services_to_reset=($(printf '%s\n' "${stale_services[@]}" | sort -u))
    just print "{{ YELLOW }}" "==> SIP blocks per-row delete, will reset these categories instead:"

    for svc in "${services_to_reset[@]}"; do
        stale_count=0
        for s in "${stale_services[@]}"; do [[ "$s" == "$svc" ]] && stale_count=$((stale_count + 1)); done
        user_total=$(sqlite3 "$HOME/Library/Application Support/com.apple.TCC/TCC.db" "SELECT COUNT(*) FROM access WHERE service='$svc';" 2>/dev/null || echo 0)
        system_total=$(sudo sqlite3 "/Library/Application Support/com.apple.TCC/TCC.db" "SELECT COUNT(*) FROM access WHERE service='$svc';" 2>/dev/null || echo 0)
        other=$((user_total + system_total - stale_count))
        printf '    %-35s %d dead / %d other\n' "$svc" "$stale_count" "$other"
    done

    just print "{{ YELLOW }}" "    Accessibility/Full Disk Access/Developer Tools won't auto-reprompt — re-add 'other' entries manually if needed."

    read -rp "Proceed? [y/N] " confirm
    [[ "$confirm" =~ ^[Yy]$ ]] || { just print "{{ YELLOW }}" "Cancelled."; exit 1; }

    for svc in "${services_to_reset[@]}"; do
        tccutil reset "${svc#kTCCService}"
    done

    just print "{{ GREEN }}" "==> Reset ${#services_to_reset[@]} categories."
