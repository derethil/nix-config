{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf getExe;
  cfg = config.desktop.aerospace;

  back-and-forth = pkgs.writeShellScriptBin "back-and-forth" ''
    ${getExe pkgs.aerospace} focus-back-and-forth || ${getExe pkgs.aerospace} workspace-back-and-forth
  '';

  mkWorkspaceBinds = mod: commands:
    lib.listToAttrs (lib.map (i: {
      name = "${mod}-${
        if i == 10
        then "0"
        else toString i
      }";
      value = lib.map (cmd: "${cmd} ${toString i}") commands;
    }) (lib.range 1 10));
in {
  config = mkIf cfg.enable {
    programs.aerospace.userSettings = {
      mode.main.binding = lib.foldl lib.mergeAttrs {} [
        {
          # Terminal shortcuts (migrated from skhd)
          alt-enter = "exec-and-forget open -n -a Alacritty --args -e ${getExe pkgs.tmux} new-session -As base";
          alt-shift-enter = "exec-and-forget open -n -a Alacritty";

          # Window management
          alt-q = "close";
          alt-f = "fullscreen";
          alt-shift-f = "macos-native-fullscreen";
          alt-shift-m = "macos-native-minimize";

          # Focus window
          alt-h = "focus left";
          alt-j = "focus down";
          alt-k = "focus up";
          alt-l = "focus right";
          alt-tab = "exec-and-forget ${getExe back-and-forth}";

          # Move window
          alt-ctrl-h = "move left";
          alt-ctrl-j = "move down";
          alt-ctrl-k = "move up";
          alt-ctrl-l = "move right";

          # Resize window
          alt-r = "mode resize";

          # Layout
          alt-t = "layout tiles horizontal vertical";
          alt-s = "layout accordion horizontal vertical";
          alt-space = "layout floating tiling";

          # Move workspace to monitor
          alt-m = "move-workspace-to-monitor --wrap-around next";

          # Navigate between workspaces
          alt-leftSquareBracket = "workspace --wrap-around prev";
          alt-rightSquareBracket = "workspace --wrap-around next";

          # Navigate between monitors
          alt-shift-leftSquareBracket = "focus-monitor --wrap-around prev";
          alt-shift-rightSquareBracket = "focus-monitor --wrap-around next";

          # Reload config
          alt-shift-r = "reload-config";
        }

        # Move to workspace
        (mkWorkspaceBinds "alt" ["workspace"])

        # Move window to workspace
        (mkWorkspaceBinds "alt-shift" ["move-node-to-workspace" "workspace"])
      ];

      mode.resize.binding = {
        minus = "resize smart -50";
        equal = "resize smart +50";
        esc = "mode main";
      };
    };
  };
}
