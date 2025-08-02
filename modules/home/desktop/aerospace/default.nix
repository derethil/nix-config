{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf getExe;
  inherit (lib.internal) mkBoolOpt;
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

  mkAppRule = appid: commands: {
    "if" = {
      app-id = appid;
    };
    run = commands;
  };

  mkTitleRule = title: commands: {
    "if" = {
      window-title-regex-substring = title;
    };
    run = commands;
  };
in {
  options.desktop.aerospace = {
    enable = mkBoolOpt false "Whether or not to enable the Aerospace window manager.";
  };

  config = mkIf cfg.enable {
    programs.aerospace = {
      enable = true;
      launchd.enable = true;
      userSettings = {
        # Basic settings
        after-startup-command = [];
        default-root-container-layout = "tiles";
        default-root-container-orientation = "auto";
        on-focused-monitor-changed = ["move-mouse monitor-lazy-center"];
        on-focus-changed = ["move-mouse window-lazy-center"];
        accordion-padding = 30;
        enable-normalization-flatten-containers = true;
        automatically-unhide-macos-hidden-apps = true; # effectively turn off cmd+h

        workspace-to-monitor-force-assignment = {
          "1" = "main";
          "2" = "main";
          "3" = "main";
          "4" = "main";
          "5" = "main";
        };

        gaps = {
          inner.horizontal = 4;
          inner.vertical = 4;
          outer.left = 8;
          outer.bottom = 8;
          outer.top = 8;
          outer.right = 8;
        };

        key-mapping = {
          preset = "qwerty";
        };

        mode.main.binding = lib.foldl lib.mergeAttrs {} [
          {
            # Terminal shortcuts (migrated from skhd)
            "alt-enter" = "exec-and-forget ${getExe pkgs.alacritty} -e ${getExe pkgs.tmux} new-session -As base";
            "alt-shift-enter" = "exec-and-forget ${getExe pkgs.alacritty}";

            # Window management
            "alt-q" = "close";
            "alt-f" = "fullscreen";
            "alt-shift-f" = "macos-native-fullscreen";
            "alt-shift-m" = "macos-native-minimize";

            # Focus window
            "alt-h" = "focus left";
            "alt-j" = "focus down";
            "alt-k" = "focus up";
            "alt-l" = "focus right";
            alt-tab = "exec-and-forget ${getExe back-and-forth}";

            # Move window
            "alt-ctrl-h" = "move left";
            "alt-ctrl-j" = "move down";
            "alt-ctrl-k" = "move up";
            "alt-ctrl-l" = "move right";

            # Resize window
            "alt-r" = "mode main";

            # Layout
            "alt-t" = "layout tiles horizontal vertical";
            "alt-s" = "layout accordion horizontal vertical";
            "alt-space" = "layout floating tiling";

            # Focus monitor
            "alt-shift-space" = "focus-monitor --wrap-around next";

            # Move workspace to monitor
            "alt-m" = "move-workspace-to-monitor --wrap-around next";

            # Navigate between workspaces
            "alt-leftSquareBracket" = "workspace --wrap-around prev";
            "alt-rightSquareBracket" = "workspace --wrap-around next";

            # Reload config
            "alt-shift-r" = "reload-config";
          }
          # Move to workspace
          (mkWorkspaceBinds "alt" ["workspace"])

          # Move window to workspace
          (mkWorkspaceBinds "alt-shift" ["move-node-to-workspace" "workspace"])
        ];

        mode.resize.binding = {
          "minus" = "resize smart -50";
          "equal" = "resize smart +50";
          "esc" = "mode main";
        };

        on-window-detected = [
          # Float rules
          (mkAppRule "com.apple.systempreferences" "layout floating")
          (mkAppRule "com.apple.ActivityMonitor" "layout floating")
          (mkAppRule "com.apple.Finder" "layout floating")
          (mkTitleRule "Bitwarden" "layout floating")

          # Workspace assignment rules
          (mkAppRule "org.nixos.Firefox" "move-node-to-workspace 1")
          (mkAppRule "org.alacritty" "move-node-to-workspace 2")
          (mkAppRule "com.hnc.Discord" "move-node-to-workspace 3")
          (mkAppRule "com.apple.MobileSMS" "move-node-to-workspace 3")
          (mkAppRule "com.insomnia.app" "move-node-to-workspace 4")
          (mkAppRule "md.obsidian" "move-node-to-workspace 4")
          (mkAppRule "org.gorilladevs.GDLauncher" "move-node-to-workspace 5")
          (mkAppRule "com.smartcodeltd.stremio" "move-node-to-workspace 5")
          (mkAppRule "com.spotify.client" "move-node-to-workspace 5")
        ];
      };
    };
  };
}
