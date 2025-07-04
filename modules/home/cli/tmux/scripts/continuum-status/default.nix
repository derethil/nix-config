{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
with internal; let
  tmux-continuum-status = pkgs.writeShellScriptBin "tmux-continuum-status" ''
    #!${pkgs.bash}/bin/bash

    CONTINUUM_DIR="${pkgs.tmuxPlugins.continuum}/share/tmux-plugins/continuum/scripts"

    source "$CONTINUUM_DIR/helpers.sh"
    source "$CONTINUUM_DIR/variables.sh"
    source "$CONTINUUM_DIR/shared.sh"

    seconds_remaining() {
      local last_saved_timestamp
      local interval_minutes
      local now

      last_saved_timestamp="$(get_tmux_option "$last_auto_save_option" "0")"
      interval_minutes="$(get_tmux_option "$auto_save_interval_option" "$auto_save_interval_default")"
      now="$(date +%s)"

      local interval_seconds="$((interval_minutes * 60))"
      local next_run="$((last_saved_timestamp + interval_seconds))"
      local remaining="$((next_run - now))"

      echo "$remaining"
    }

    format_status() {
      remaining=$1

      local minutes=$((remaining % 3600 / 60))
      local seconds=$((remaining % 60))

      ((seconds >= 30)) && ((minutes++))

      if [ "$minutes" -eq 0 ]; then
        formatted="<1m"
      else
        formatted="''${minutes}m"
      fi

      echo "$formatted"
    }

    get_status() {
      local save_int
      local status
      local style_wrap

      style_wrap="$(get_tmux_option "$status_on_style_wrap_option" "")"
      save_int="$(get_tmux_option "$auto_save_interval_option")"

      if [ "$save_int" -gt 0 ]; then
        status="$(format_status "$(seconds_remaining)")"
      else
        style_wrap="$(get_tmux_option "$status_off_style_wrap_option" "")"
        status="off"
      fi

      if [ -n "$style_wrap" ]; then
        status="''${style_wrap/$status_wrap_string/$status}"
      fi

      echo "$status"
    }

    get_status
  '';
in {
  config = mkIf config.cli.tmux.enable {
    home.packages = [tmux-continuum-status];
  };
}
