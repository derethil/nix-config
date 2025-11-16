{
  pkgs,
  lib,
  ...
}:
pkgs.writeShellApplication {
  name = "ff";

  runtimeInputs = with pkgs; [
    plocate
    fzf
    wl-clipboard
  ];

  meta = {
    platforms = lib.platforms.linux;
  };

  text = ''
    set -euo pipefail

    # Check if we have any arguments
    if [ $# -eq 0 ]; then
      echo "usage: ff <search_pattern>" >&2
      echo "example: ff '*.conf'" >&2
      exit 1
    fi

    # Use locate to find files and pipe to fzf for selection
    selected_file=$(locate "$@" 2>/dev/null | fzf --prompt="Select file: " --height=50% --border)

    # Check if user selected a file
    if [ -n "$selected_file" ]; then
      # Echo the selected path
      echo "$selected_file"

      # Copy to clipboard using wl-clipboard (Wayland) or xclip (X11)
      if command -v wl-copy &> /dev/null; then
        echo -n "$selected_file" | wl-copy
      elif command -v xclip &> /dev/null; then
        echo -n "$selected_file" | xclip -selection clipboard
      else
        echo "Warning: No clipboard utility found (wl-copy or xclip)" >&2
      fi
    else
      exit 1
    fi
  '';
}
