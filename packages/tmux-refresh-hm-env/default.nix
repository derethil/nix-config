{
  pkgs,
  config,
  lib,
  ...
}:
pkgs.writeShellScriptBin "tmux-refresh-hm-env" ''
  #!/usr/bin/env bash

  # Setup logging - use XDG_STATE_HOME which is set by Home Manager
  LOG_DIR="''${XDG_STATE_HOME:-$HOME/.local/state}/tmux/logs"
  LOG_FILE="$LOG_DIR/refresh-env.log"
  mkdir -p "$LOG_DIR"

  # Function to log with timestamp
  log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') $1" >> "$LOG_FILE"
  }

  # Check if tmux server is running
  if ! tmux list-sessions >/dev/null 2>&1; then
    log "No tmux server running, nothing to refresh"
    exit 0
  fi

  # Get all session variables from Home Manager and system configuration
  session_vars=(
    ${lib.concatStringsSep "\n" (lib.mapAttrsToList (name: value: ''"${name}"'') (config.home.sessionVariables or {}))}
    ${lib.concatStringsSep "\n" (lib.mapAttrsToList (name: value: ''"${name}"'') (config.environment.sessionVariables or {}))}
  )

  # Add additional variables from tmux module
  session_vars+=(
    ${lib.concatStringsSep "\n" (map (var: "    \"${var}\"") (config.cli.tmux.extraVariables or []))}
  )

  # Also include common environment variables that might change
  session_vars+=(
    "SSH_AUTH_SOCK"
    "SSH_CONNECTION"
    "DISPLAY"
    "WAYLAND_DISPLAY"
    "XDG_SESSION_ID"
    "XDG_SESSION_CLASS"
  )

  log "Starting tmux environment refresh"

  # Set variables in tmux global environment
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
