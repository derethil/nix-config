# Display Renovate maintenance recipes
default:
    @just --list renovate

# Regenerate source hashes after Renovate updates package versions
[no-cd, positional-arguments]
regen-nix-hashes *files:
    #!/usr/bin/env bash
    set -euo pipefail

    fake_hash="sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="
    hash_pattern='sha256-[A-Za-z0-9+/=]\+'
    files=("$@")

    if [[ ${#files[@]} -eq 0 ]]; then
      mapfile -t files < <(git ls-files '*.nix')
    fi

    backup_copy=""
    backup_of=""

    restore_backup() {
      [[ -n "$backup_copy" ]] || return 0
      cp "$backup_copy" "$backup_of"
      rm -f "$backup_copy"
      backup_copy=""
    }

    trap restore_backup EXIT INT TERM

    set_hash() {
      local file="$1"
      local line="$2"
      local hash="$3"

      sed -i "${line}s|${hash_pattern}|${hash}|" "$file"
    }

    regenerate_url_hashes() {
      local file="$1"
      local marker_line
      local attribute
      local hash_line
      local old_hash
      local url
      local new_hash

      while IFS=: read -r marker_line _; do
        attribute="$(sed -n "${marker_line}s/.*regen-hash-url:[[:space:]]*//p" "$file")"
        hash_line=$((marker_line + 1))
        old_hash="$(sed -n "${hash_line}p" "$file" | grep -o "$hash_pattern" || true)"

        if [[ -z "$attribute" || -z "$old_hash" ]]; then
          echo "$file:$marker_line: regen-hash-url marker requires a URL attribute and a hash on the next line" >&2
          return 1
        fi

        url="$(nix eval --raw ".#${attribute}")"
        new_hash="$(nix store prefetch-file --hash-type sha256 --json "$url" | jq -er '.hash')"

        if [[ "$new_hash" == "$old_hash" ]]; then
          echo "CURRENT $file:$hash_line $attribute"
          continue
        fi

        set_hash "$file" "$hash_line" "$new_hash"
        echo "UPDATED $file:$hash_line $attribute"
        echo "  was $old_hash"
        echo "  now $new_hash"
      done < <(grep -n '^[[:space:]]*#[[:space:]]*regen-hash-url:' "$file" || true)
    }

    regenerate_marked_hashes() {
      local file="$1"
      local marker_line
      local attribute
      local hash_line
      local old_hash
      local output
      local new_hash

      while IFS=: read -r marker_line _; do
        attribute="$(sed -n "${marker_line}s/.*regen-hash:[[:space:]]*//p" "$file")"
        hash_line=$((marker_line + 1))
        old_hash="$(sed -n "${hash_line}p" "$file" | grep -o "$hash_pattern" || true)"

        if [[ -z "$attribute" || -z "$old_hash" ]]; then
          echo "$file:$marker_line: regen-hash marker requires a flake attribute and a hash on the next line" >&2
          return 1
        fi

        backup_of="$file"
        backup_copy="$(mktemp)"
        cp "$file" "$backup_copy"
        set_hash "$file" "$hash_line" "$fake_hash"

        if output="$(nix build --no-link ".#${attribute}" 2>&1)"; then
          echo "$attribute built successfully with a fake hash" >&2
          return 1
        fi

        restore_backup

        new_hash="$(grep -o "got:[[:space:]]*${hash_pattern}" <<<"$output" | tail -n 1 | grep -o "$hash_pattern" || true)"
        if [[ -z "$new_hash" ]]; then
          echo "No hash mismatch was reported while building $attribute:" >&2
          echo "$output" >&2
          return 1
        fi

        if [[ "$new_hash" == "$old_hash" ]]; then
          echo "CURRENT $file:$hash_line $attribute"
          continue
        fi

        set_hash "$file" "$hash_line" "$new_hash"
        echo "UPDATED $file:$hash_line $attribute"
        echo "  was $old_hash"
        echo "  now $new_hash"
      done < <(grep -n '^[[:space:]]*#[[:space:]]*regen-hash:' "$file" || true)
    }

    for file in "${files[@]}"; do
      [[ -f "$file" ]] || continue
      regenerate_url_hashes "$file"
      regenerate_marked_hashes "$file"
    done
