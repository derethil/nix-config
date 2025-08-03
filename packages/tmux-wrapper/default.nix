{
  pkgs,
  config,
  lib,
  ...
}: let
  refresh-env = lib.getExe (pkgs.internal.tmux-refresh-hm-env.override {inherit config lib;});
in
  pkgs.symlinkJoin {
    name = "tmux";
    paths = [pkgs.tmux];
    buildInputs = [pkgs.makeWrapper];
    postBuild = ''
      wrapProgram $out/bin/tmux \
        --run 'case "$1" in attach-session|attach|a|new-session|new|kill-server|kill-ses*) if [[ -x "${refresh-env}" ]]; then "${refresh-env}" >/dev/null 2>&1 || true; fi ;; esac'
    '';
  }
