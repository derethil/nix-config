{
  programs.fish.interactiveShellInit = ''
    set -x fish_color_autosuggestion 555\x1ebrblack
    set -x fish_color_cancel \x2dr
    set -x fish_color_command blue
    set -x fish_color_comment red
    set -x fish_color_cwd green
    set -x fish_color_cwd_root red
    set -x fish_color_end green
    set -x fish_color_error brred
    set -x fish_color_escape brcyan
    set -x fish_color_history_current \x2d\x2dbold
    set -x fish_color_host normal
    set -x fish_color_host_remote yellow
    set -x fish_color_normal normal
    set -x fish_color_operator brcyan
    set -x fish_color_param cyan
    set -x fish_color_quote yellow
    set -x fish_color_redirection cyan\x1e\x2d\x2dbold
    set -x fish_color_search_match white\x1e\x2d\x2dbackground\x3dbrblack
    set -x fish_color_selection white\x1e\x2d\x2dbold\x1e\x2d\x2dbackground\x3dbrblack
    set -x fish_color_status red
    set -x fish_color_user brgreen
    set -x fish_color_valid_path \x2d\x2dunderline
    set -x fish_key_bindings fish_vi_key_bindings
    set -x fish_pager_color_completion normal
    set -x fish_pager_color_description B3A06D\x1eyellow\x1e\x2di
    set -x fish_pager_color_prefix normal\x1e\x2d\x2dbold\x1e\x2d\x2dunderline
    set -x fish_pager_color_progress brwhite\x1e\x2d\x2dbackground\x3dcyan
    set -x fish_pager_color_selected_background \x2dr
  '';
}
