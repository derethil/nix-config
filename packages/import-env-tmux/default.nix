{pkgs, ...}:
pkgs.writeShellScriptBin "import-env-tmux" ''
  #!/usr/bin/env bash
  set -e

  # Skip if debug mode is enabled
  [[ -n $HYPRLAND_DEBUG_CONF ]] && exit 0

  USAGE="\
  Import environment variables

  Usage: $0 <command> [additional_vars...]

  Commands:
     tmux         import to tmux server
     system       import to systemd and dbus user session
     help         print this help

  Optional:
     additional_vars    Additional environment variables to import (space separated)
  "

  # Base environment variables common across window managers
  _envs=(
    # Display
    WAYLAND_DISPLAY
    DISPLAY
    # XDG
    USERNAME
    XDG_BACKEND
    XDG_SESSION_ID
    XDG_SESSION_CLASS
    XDG_SEAT
    XDG_VTNR
    # toolkit
    _JAVA_AWT_WM_NONREPARENTING
    # ssh
    SSH_AUTH_SOCK
  )

  # Add any additional environment variables passed as arguments
  if [[ $# -gt 1 ]]; then
    shift # Remove the first argument (the command)
    for var in "$@"; do
      _envs+=("$var")
    done
  fi

  case "$1" in
  system)
    dbus-update-activation-environment --systemd "''${_envs[@]}"
    ;;
  tmux)
    for v in "''${_envs[@]}"; do
      if [[ -n ''${!v} ]]; then
        tmux setenv -g "$v" "''${!v}"
      fi
    done
    ;;
  help)
    echo -n "$USAGE"
    exit 0
    ;;
  *)
    echo "operation required"
    echo "use \"$0 help\" to see usage help"
    exit 1
    ;;
  esac
''
