{
  self,
  lib,
  ...
}: {
  flake.lib.niri.mkKeybinds = props: options:
    lib.mkMerge [
      {_props = props;}
      options
    ];

  flake.modules.homeManager.niri = {
    config,
    pkgs,
    lib,
    ...
  }: let
    inherit (lib) mkMerge mkDefault mkIf getExe;
    inherit (self.lib.niri) mkKeybinds;
    cfg = config.surfaces.niri;
    dmsEnabled = config.programs.dank-material-shell.enable or false;

    mkWorkspaceBinds = modifier: action:
      builtins.listToAttrs (map (
        i: let
          key =
            if i == 10
            then 0
            else i;
        in {
          name = "${modifier}+${toString key}";
          value.${action} = i;
        }
      ) (lib.range 1 10));

    equalizeColumns = pkgs.writeShellApplication {
      name = "niri-equalize-columns";
      runtimeInputs = [pkgs.jq];
      text = ''
        workspace_id=$(niri msg --json workspaces | jq '[.[] | select(.is_active==true)] | .[0].id')

        col_count=$(niri msg --json windows | jq --argjson ws "$workspace_id" '
          [.[] | select(.workspace_id==$ws and .is_floating==false) | .layout.pos_in_scrolling_layout[0]]
          | unique | length
        ')

        if [[ -z "$col_count" || "$col_count" -le 0 ]]; then
          exit 1
        fi

        width=$((100 / col_count))

        for i in $(seq 1 "$col_count"); do
          niri msg action focus-column "$i"
          niri msg action set-column-width "''${width}%"
        done

        niri msg action focus-column 1
        niri msg action center-visible-columns
      '';
    };

    mkMenu = menu: let
      font = config.font.monospace;
      niriCfg = config.wayland.windowManager.niri.settings;
      configFile =
        builtins.toFile "config.yaml"
        (lib.generators.toYAML {} {
          inherit menu;
          font = "${font.name} ${toString font.size}";
          anchor = "bottom-right";
          background = "#282828";
          color = "#D4BE98";
          inhibit_compositor_keyboard_shortcuts = true;
          corner_r = 8; # can't pull from niri settings because it's a rule not a setting
          border_width = niriCfg.layout.border.width;
          margin_right = niriCfg.layout.gaps + niriCfg.layout.struts.right;
          margin_bottom = niriCfg.layout.gaps + niriCfg.layout.struts.bottom;
        });
    in
      pkgs.writeShellScriptBin "wlr-which-key-menu" ''
        exec ${getExe pkgs.wlr-which-key} ${configFile}
      '';
  in {
    imports = with self.modules.homeManager; [
      niri-smart-workspace
      niri-hyprpicker
      niri-wlsunset
      niri-window-picker-menu
      terminal-options
    ];

    shell.aliases.kill-window = "kill -9 $(niri msg -j pick-window | jq -r '.pid')";

    wayland.windowManager.niri.settings.binds = mkMerge [
      {
        # Overview
        "Mod+Tab" = {toggle-overview = [];};

        # Exit Session
        "Mod+Shift+E" = mkKeybinds {hotkey-overlay-title = "Exit Session";} {
          quit._props.skip-confirmation = true;
        };

        # Window State Management
        "Mod+Q" = {close-window = [];};
        "Mod+Shift+Q" = mkKeybinds {hotkey-overlay-title = "Close Window (Pick)";} {
          spawn = ["niri-window-picker-menu" "niri msg action close-window --id {{id}}"];
        };
        "Mod+O" = mkKeybinds {hotkey-overlay-title = "Cast Window (Pick)";} {
          spawn = ["bash" "-c" "niri msg action set-dynamic-cast-window --id $(niri msg --json pick-window | jq .id)"];
        };
        "Mod+F" = {fullscreen-window = [];};
        "Mod+Shift+F" = {toggle-windowed-fullscreen = [];};
        "Mod+M" = {maximize-window-to-edges = [];};
        "Mod+Space" = {switch-focus-between-floating-and-tiling = [];};
        "Mod+Shift+Space" = {toggle-window-floating = [];};
        "Mod+MouseForward" = {toggle-window-floating = [];};

        # Focus Windows
        "Mod+Comma" = {focus-column-first = [];};
        "Mod+Period" = {focus-column-last = [];};
        "Mod+H" = {focus-column-left = [];};
        "Mod+L" = {focus-column-right = [];};
        "Mod+K" = {focus-window-up = [];};
        "Mod+J" = {focus-window-down = [];};

        # Move within Workspace
        "Mod+Shift+Comma" = {move-column-to-first = [];};
        "Mod+Shift+Period" = {move-column-to-last = [];};
        "Mod+Shift+H" = {move-column-left = [];};
        "Mod+Shift+L" = {move-column-right = [];};
        "Mod+Shift+K" = {move-window-up = [];};
        "Mod+Shift+J" = {move-window-down = [];};
        "Mod+Ctrl+H" = {consume-or-expel-window-left = [];};
        "Mod+Ctrl+L" = {consume-or-expel-window-right = [];};

        # Resize
        "Mod+W" = mkKeybinds {hotkey-overlay-title = "Equalize Columns";} {
          spawn-sh = [(getExe equalizeColumns)];
        };
        "Mod+S" = {toggle-column-tabbed-display = [];};
        "Mod+R" = mkKeybinds {hotkey-overlay-title = "Resize Column";} {
          spawn-sh = [
            (getExe (mkMenu [
              {
                key = "s";
                desc = "1/3 width";
                cmd = "niri msg action set-column-width 33%";
              }
              {
                key = "d";
                desc = "1/2 width";
                cmd = "niri msg action set-column-width 50%";
              }
              {
                key = "f";
                desc = "2/3 width";
                cmd = "niri msg action set-column-width 67%";
              }
              {
                key = "g";
                desc = "Full width";
                cmd = "niri msg action set-column-width 100%";
              }
            ]))
          ];
        };

        # Workspace navigation — smart-workspace overrides at higher priority when imported.
        "Mod+BracketLeft" = mkDefault {focus-workspace-up = [];};
        "Mod+BracketRight" = mkDefault {focus-workspace-down = [];};
        "Mod+WheelScrollUp" = mkDefault {focus-workspace-up = [];};
        "Mod+WheelScrollDown" = mkDefault {focus-workspace-down = [];};
        "Mod+Backspace" = {focus-workspace-previous = [];};
      }

      # Workspace 1-10 binds
      (mkWorkspaceBinds "Mod" "focus-workspace")
      (mkWorkspaceBinds "Mod+Shift" "move-column-to-workspace")

      # DMS-disabled fallbacks — niri owns these when DMS isn't in the surface.
      (mkIf (!dmsEnabled) {
        "Mod+Shift+Slash" = mkKeybinds {hotkey-overlay-title = "Show Hotkey Overlay";} {
          spawn-sh = ["niri" "msg" "action" "show-hotkey-overlay"];
        };
        "Print" = mkKeybinds {hotkey-overlay-title = "Take Screenshot";} {
          spawn-sh = ["niri" "msg" "action" "screenshot"];
        };
      })

      # Audio
      (mkIf cfg.binds.defaultAudioBinds {
        "XF86AudioRaiseVolume" = mkKeybinds {
          hotkey-overlay-title = "Increase Volume";
          allow-when-locked = true;
        } {spawn-sh = ["wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1+"];};
        "XF86AudioLowerVolume" = mkKeybinds {
          hotkey-overlay-title = "Decrease Volume";
          allow-when-locked = true;
        } {spawn-sh = ["wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1-"];};
        "XF86AudioMute" = mkKeybinds {
          hotkey-overlay-title = "Toggle Mute";
          allow-when-locked = true;
        } {spawn-sh = ["wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"];};

        "Ctrl+XF86AudioRaiseVolume" = mkKeybinds {
          hotkey-overlay-title = "Increase Mic Volume";
          allow-when-locked = true;
        } {spawn-sh = ["wpctl" "set-volume" "@DEFAULT_AUDIO_SOURCE@" "0.1+"];};
        "Ctrl+XF86AudioLowerVolume" = mkKeybinds {
          hotkey-overlay-title = "Decrease Mic Volume";
          allow-when-locked = true;
        } {spawn-sh = ["wpctl" "set-volume" "@DEFAULT_AUDIO_SOURCE@" "0.1-"];};
        "Ctrl+XF86AudioMute" = mkKeybinds {
          hotkey-overlay-title = "Toggle Mic Mute";
          allow-when-locked = true;
        } {spawn-sh = ["wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle"];};
      })

      # Brightness
      (mkIf cfg.binds.defaultBrightnessBinds {
        "XF86MonBrightnessUp" = mkKeybinds {
          hotkey-overlay-title = "Increase Brightness";
          allow-when-locked = true;
        } {spawn-sh = ["brightnessctl" "set" "10%+"];};
        "XF86MonBrightnessDown" = mkKeybinds {
          hotkey-overlay-title = "Decrease Brightness";
          allow-when-locked = true;
        } {spawn-sh = ["brightnessctl" "set" "10%-"];};
      })

      # Terminal Shortcuts — only when a terminal has registered itself.
      (mkIf (config.terminal.commands.base != []) {
        "Mod+Return" = mkKeybinds {hotkey-overlay-title = "Open Terminal (tmux)";} {
          spawn = config.terminal.commands.withTmux;
        };
        "Mod+Shift+Return" = mkKeybinds {hotkey-overlay-title = "Open Terminal";} {
          spawn = config.terminal.commands.base;
        };
      })
    ];
  };
}
