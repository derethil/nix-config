{
  lib,
  pkgs,
  ...
}:
pkgs.writeShellScriptBin "tmux-ssh-launch" ''
  #!${lib.getExe pkgs.bash}

  local_session="$(cat "''${XDG_RUNTIME_DIR:-/tmp}/tmux-ssh-session" 2>/dev/null)"

  answer_file="''${XDG_RUNTIME_DIR:-/tmp}/tmux-ssh-popup-answer"
  [[ -s "$answer_file" ]] || {
    [[ -n "$local_session" ]] && exec tmux attach -t "$local_session"
    exit 0
  }

  host="$(sed -n '1p' "$answer_file")"
  session="$(sed -n '2p' "$answer_file")"
  read -ra ports <<< "$(sed -n '3p' "$answer_file")"
  rm -f "$answer_file"

  session="''${session:-main}"

  forwards=()
  for port in "''${ports[@]}"; do
    forwards+=(-L "''${port}:localhost:''${port}")
  done

  read -r lines cols < <(stty size)

  ssh "''${forwards[@]}" -t "$host" "tmux -u new -A -s '$session' -x $cols -y $lines"
  tput reset 2>/dev/null || true

  [[ -n "$local_session" ]] && exec tmux attach -t "$local_session"
''
