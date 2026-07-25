{
  pkgs,
  refresh-env,
  ...
}:
pkgs.symlinkJoin {
  buildInputs = [pkgs.makeWrapper];
  name = "tmux";
  paths = [pkgs.tmux];

  postBuild = ''
    wrapProgram $out/bin/tmux \
      --run 'case "$1" in attach-session|attach|a|new-session|new|kill-server|kill-ses*) if [[ -x "${refresh-env}" ]]; then "${refresh-env}" >/dev/null 2>&1 || true; fi ;; esac'
  '';
}
