# Requires https://github.com/tmux-plugins/tmux-continuum/

show_continuum() {
  local index icon color text module

  index=$1

  icon="$(get_tmux_option "@theme_continuum_icon" "󰆓")"
  color="$(get_tmux_option "@theme_continuum_color" "$thm_blue")"
  text="$(get_tmux_option "@theme_continuum_text" "$(tmux-continuum-status)")"

  module=$(build_status_module "$index" "$icon" "$color" "$text")

  echo "$module"
}
