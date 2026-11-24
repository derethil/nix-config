{
  lib,
  pkgs,
  hosts,
  ssh-launch,
  ...
}:
pkgs.writeShellScriptBin "tmux-ssh-select" ''
  #!${lib.getExe pkgs.bash}

  answer_file="''${XDG_RUNTIME_DIR:-/tmp}/tmux-ssh-popup-answer"
  rm -f "$answer_file"

  hosts=(${lib.concatStringsSep " " hosts})
  current="$(hostname -s)"

  choices=()
  for h in "''${hosts[@]}"; do
    [[ "$h" != "$current" ]] && choices+=("$h")
  done

  host="$(printf '%s\n' "''${choices[@]}" | ${lib.getExe pkgs.fzf} --prompt="Remote host: " --layout=reverse --border)"
  [[ -z "$host" ]] && exit 0

  sessions="$(ssh -o BatchMode=yes -o ConnectTimeout=5 "$host" "tmux list-sessions -F '#S'" 2>/dev/null)"

  result="$(printf '%s\n' "$sessions" | ${lib.getExe pkgs.fzf} --print-query --prompt="Session on $host: " --layout=reverse --border)"
  [[ $? -ne 0 ]] && exit 0

  query="$(sed -n '1p' <<< "$result")"
  selection="$(sed -n '2p' <<< "$result")"
  session="''${selection:-$query}"

  read -rp "Forward ports (space-separated, blank for none): " -a ports

  {
    echo "$host"
    echo "$session"
    echo "''${ports[*]}"
  } > "$answer_file"

  [[ -s "$answer_file" ]] && exec tmux detach-client -E "${ssh-launch}"
''
