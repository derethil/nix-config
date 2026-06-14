{writeShellScriptBin}:
writeShellScriptBin "git-prune-merged" ''
  set -euo pipefail

  if [ $# -ne 1 ]; then
    echo "Usage: git-prune-merged <branch>" >&2
    exit 1
  fi

  branch="$1"

  if ! git rev-parse --verify "$branch" >/dev/null 2>&1; then
    echo "Branch '$branch' does not exist" >&2
    exit 1
  fi

  current="$(git symbolic-ref --quiet --short HEAD || true)"

  mapfile -t merged < <(
    git branch --merged "$branch" --format='%(refname:short)' \
      | grep -Fxv -e "$branch" -e "$current"
  )

  if [ ''${#merged[@]} -eq 0 ]; then
    echo "No branches to prune"
    exit 0
  fi

  printf '%s\n' "''${merged[@]}" | xargs -n 1 git branch -d
  git fetch --prune
''
