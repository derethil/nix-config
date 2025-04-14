# Requires https://github.com/tmux-plugins/tmux-continuum/

BASH_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_DIR="$(cd "$BASH_DIR/../scripts" && pwd)"

show_continuum() {
  local index icon color text module script_dir

  index=$1

  script_dir="$(get_tmux_option "@theme_custom_script_dir" "$SCRIPT_DIR")"
  icon="$(get_tmux_option "@theme_continuum_icon" "󰆓")"
  color="$(get_tmux_option "@theme_continuum_color" "$thm_blue")"
  text="$(get_tmux_option "@theme_continuum_text" "#( $script_dir/continuum_status.sh )")"

  module=$(build_status_module "$index" "$icon" "$color" "$text")

  echo "$module"
}
