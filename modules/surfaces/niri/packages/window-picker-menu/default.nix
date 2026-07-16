{
  flake.modules.homeManager.niri-window-picker-menu = {
    config,
    pkgs,
    ...
  }: let
    font = config.font.monospace;
    niriCfg = config.wayland.windowManager.niri.settings;

    styleFile = pkgs.writeText "niri-window-picker-style.yaml" ''
      font: "${font.name} ${toString font.size}"
      anchor: center
      background: "#282828"
      color: "#D4BE98"
      inhibit_compositor_keyboard_shortcuts: true
      corner_r: 8
      border_width: ${toString niriCfg.layout.border.width}
    '';
  in {
    home.packages = [
      (pkgs.writeShellApplication {
        name = "niri-window-picker-menu";
        runtimeInputs = with pkgs; [jq niri wlr-which-key];
        text = ''
          cmd_template="''${1:-}"
          if [[ -z "$cmd_template" ]]; then
            printf 'error: a command template is required (use {{id}} as the window ID placeholder)\n' >&2
            exit 1
          fi

          keys=(h j k l a s d f g y u i o p q w e r t n m z x c v b \
                6 7 8 9 0 1 2 3 4 5)

          tmpfile=$(mktemp /tmp/wlr-window-picker-XXXXXX.yaml)
          trap 'rm -f "$tmpfile"' EXIT

          windows=$(niri msg --json windows)
          count=$(echo "$windows" | jq 'length')

          {
            cat ${styleFile}
            echo "menu:"
            for ((i = 0; i < count && i < ''${#keys[@]}; i++)); do
              key="''${keys[$i]}"
              id=$(echo "$windows" | jq -r ".[$i].id")
              desc=$(echo "$windows" | jq -j ".[$i] | \"\(.app_id)\" | @json")
              cmd="''${cmd_template//\{\{id\}\}/$id}"
              printf '  - key: "%s"\n' "$key"
              printf '    desc: %s\n' "$desc"
              printf '    cmd: %s\n' "$cmd"
            done
          } > "$tmpfile"

          wlr-which-key "$tmpfile"
        '';
      })
    ];
  };
}
