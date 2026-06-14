{lib, ...}: {
  perSystem = {
    system,
    pkgs,
    ...
  }:
    lib.optionalAttrs (lib.elem system lib.platforms.linux) {
      packages.ff = pkgs.writeShellApplication {
        name = "ff";

        runtimeInputs = with pkgs; [
          plocate
          fzf
          wl-clipboard
        ];

        meta.platforms = lib.platforms.linux;

        text = ''
          set -euo pipefail

          # Parse options
          db_path=""
          while [[ $# -gt 0 ]]; do
            case $1 in
              --db|-d)
                db_path="$2"
                shift 2
                ;;
              *)
                break
                ;;
            esac
          done

          if [ $# -eq 0 ]; then
            echo "usage: ff [--db <database_path>] <search_pattern>" >&2
            echo "example: ff '*.conf'" >&2
            echo "example: ff --db /path/to/db '*.conf'" >&2
            exit 1
          fi

          locate_cmd="locate"
          if [ -n "$db_path" ]; then
            locate_cmd="locate --database $db_path"
          fi

          selected_file=$($locate_cmd "$@" 2>/dev/null | fzf --prompt="Select file: " --height=50% --border)

          if [ -n "$selected_file" ]; then
            echo "$selected_file"

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
      };
    };
}
