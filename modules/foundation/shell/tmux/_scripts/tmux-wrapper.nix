{
  pkgs,
  refresh-env,
  ...
}:
pkgs.symlinkJoin {
  name = "tmux";
  paths = [pkgs.tmux];
  buildInputs = [pkgs.makeWrapper];
  postBuild = ''
    wrapProgram $out/bin/tmux \
      --run 'case "$1" in attach-session|attach|a|new-session|new|kill-server|kill-ses*) if [[ -x "${refresh-env}" ]]; then "${refresh-env}" >/dev/null 2>&1 || true; fi ;; esac'
  '';
}
