{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkIf getExe types;
  inherit (lib.glace) mkBoolOpt mkOpt;
  cfg = config.glace.desktop.xdg-terminal-exec;
in {
  options.glace.desktop.xdg-terminal-exec = {
    enable = mkBoolOpt false "Whether to enable xdg-terminal-exec.";
    default = mkOpt (types.listOf types.str) [] "The default terminal emulator to use for XDG terminal-exec.";
  };

  config = mkIf cfg.enable {
    xdg.terminal-exec = {
      enable = true;
      package = pkgs.xdg-terminal-exec-mkhl;
      settings = {
        default = cfg.default;
      };
    };

    home.packages = [
      (pkgs.writeShellScriptBin "xdg-terminal-exec-wrapped" ''
        app_id=""
        args=()

        while [[ $# -gt 0 ]]; do
          case $1 in
            --app-id)
              app_id="$2"
              shift 2
              ;;
            *)
              args+=("$1")
              shift
              ;;
          esac
        done

        if [[ -z "$app_id" ]]; then
          exec ${getExe config.xdg.terminal-exec.package} "''${args[@]}"
        fi

        config_file="$HOME/.config/xdg-terminals.list"
        if [[ -f "$config_file" ]]; then
          default_terminal=$(head -n 1 "$config_file")
        else
          default_terminal=""
        fi

        case "$default_terminal" in
          kitty.desktop)
            terminal_flag="--class"
            ;;
          foot.desktop)
            terminal_flag="-a"
            ;;
          Alacritty.desktop)
            terminal_flag="--class"
            ;;
          *)
            echo "Unknown terminal: $default_terminal" >&2
            echo "Supported terminals: kitty.desktop, foot.desktop, Alacritty.desktop" >&2
            exit 1
            ;;
        esac

        exec ${getExe config.xdg.terminal-exec.package} "$terminal_flag" "$app_id" "''${args[@]}"
      '')
    ];
  };
}
