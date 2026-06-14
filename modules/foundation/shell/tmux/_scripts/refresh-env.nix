{
  pkgs,
  lib,
  config,
  ...
}:
pkgs.writeShellScriptBin "tmux-refresh-hm-env" ''
  LOG_DIR="''${XDG_STATE_HOME:-$HOME/.local/state}/tmux/logs"
  LOG_FILE="$LOG_DIR/refresh-env.log"
  mkdir -p "$LOG_DIR"

  log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') $1" >> "$LOG_FILE"
  }

  if ! tmux list-sessions >/dev/null 2>&1; then
    log "No tmux server running, nothing to refresh"
    exit 0
  fi

  session_vars=(
    ${lib.concatStringsSep "\n    " (lib.mapAttrsToList (name: _: ''"${name}"'') (config.home.sessionVariables or {}))}
    ${lib.concatStringsSep "\n    " (lib.mapAttrsToList (name: _: ''"${name}"'') (config.environment.sessionVariables or {}))}
    "SSH_AUTH_SOCK"
    "SSH_CONNECTION"
    "DISPLAY"
    "WAYLAND_DISPLAY"
    "XDG_SESSION_ID"
    "XDG_SESSION_CLASS"
  )

  log "Starting tmux environment refresh"

  updated_count=0
  for var in "''${session_vars[@]}"; do
    log "Processing variable: $var"
    if [[ -n "''${!var}" ]]; then
      if tmux setenv -g "$var" "''${!var}"; then
        log "Updated: $var=''${!var}"
        ((updated_count++))
      else
        log "Failed to set: $var"
      fi
    else
      log "Skipped (empty): $var"
    fi
  done

  log "Environment refresh complete! Updated $updated_count variables"
''
