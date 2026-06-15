{writeShellScriptBin}:
writeShellScriptBin "git-fixup" ''
  rev="$(git rev-parse "$1")"
  git commit --fixup "$@"
  GIT_SEQUENCE_EDITOR=true git rebase -i --autostash --autosquash $rev^
''
