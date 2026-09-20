{
  self,
  lib,
  ...
}: {
  flake = {
    modules.homeManager.niri = {
      config,
      lib,
      pkgs,
      ...
    }: let
      inherit (lib) getExe mkIf mkMerge;
      inherit (self.lib.niri) mkCategorizedKeybinds mkKeybinds;
      cfg = config.surfaces.niri;
      noctaliaEnabled = config.programs.noctalia.enable or false;

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
            anchor = "bottom-right";
            background = "#282828";
            border_width = niriCfg.layout.border.width;
            color = "#D4BE98";
            corner_r = 8; # can't pull from niri settings because it's a rule not a setting
            font = "${font.name} ${toString font.size}";
            inhibit_compositor_keyboard_shortcuts = true;
            margin_bottom = niriCfg.layout.gaps + niriCfg.layout.struts.bottom;
            margin_right = niriCfg.layout.gaps + niriCfg.layout.struts.right;
          });
      in
        pkgs.writeShellScriptBin "wlr-which-key-menu" ''
          exec ${getExe pkgs.wlr-which-key} ${configFile}
        '';
    in {
      imports = with self.modules.homeManager; [
        niri-hyprpicker
        niri-smart-workspace
        niri-window-picker-menu
        niri-wlsunset
        terminal-options
      ];

      shell.aliases.kill-window = "kill -9 $(niri msg -j pick-window | jq -r '.pid')";

      wayland.windowManager.niri.settings.binds._children = mkMerge [
        (mkIf (!noctaliaEnabled) (mkCategorizedKeybinds "Panels" {
          "Mod+Shift+Slash" = mkKeybinds {hotkey-overlay-title = "Open Hotkeys Help";} {
            spawn-sh = ["action" "msg" "niri" "show-hotkey-overlay"];
          };
        }))

        (mkIf (!noctaliaEnabled) (mkCategorizedKeybinds "Screenshots" {
          "Print" = mkKeybinds {hotkey-overlay-title = "Take Screenshot";} {
            spawn-sh = ["action" "msg" "niri" "screenshot"];
          };
        }))

        (mkIf (config.terminal.commands.base != []) (mkCategorizedKeybinds "Tools" {
          "Mod+Return" = mkKeybinds {hotkey-overlay-title = "Open Terminal (tmux)";} {
            spawn = config.terminal.commands.withTmux;
          };

          "Mod+Shift+Return" = mkKeybinds {hotkey-overlay-title = "Open Terminal";} {
            spawn = config.terminal.commands.base;
          };
        }))

        (mkIf cfg.binds.defaultAudioBinds (mkCategorizedKeybinds "Media" {
          "Ctrl+XF86AudioLowerVolume" = mkKeybinds {
            allow-when-locked = true;
            hotkey-overlay-title = "Decrease Mic Volume";
          } {spawn-sh = ["wpctl" "set-volume" "@DEFAULT_AUDIO_SOURCE@" "0.1-"];};

          "Ctrl+XF86AudioMute" = mkKeybinds {
            allow-when-locked = true;
            hotkey-overlay-title = "Toggle Mic Mute";
          } {spawn-sh = ["wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle"];};

          "Ctrl+XF86AudioRaiseVolume" = mkKeybinds {
            allow-when-locked = true;
            hotkey-overlay-title = "Increase Mic Volume";
          } {spawn-sh = ["wpctl" "set-volume" "@DEFAULT_AUDIO_SOURCE@" "0.1+"];};

          "XF86AudioLowerVolume" = mkKeybinds {
            allow-when-locked = true;
            hotkey-overlay-title = "Decrease Volume";
          } {spawn-sh = ["wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1-"];};

          "XF86AudioMute" = mkKeybinds {
            allow-when-locked = true;
            hotkey-overlay-title = "Toggle Mute";
          } {spawn-sh = ["wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"];};

          "XF86AudioRaiseVolume" = mkKeybinds {
            allow-when-locked = true;
            hotkey-overlay-title = "Increase Volume";
          } {spawn-sh = ["wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1+"];};
        }))

        (mkIf cfg.binds.defaultBrightnessBinds (
          mkCategorizedKeybinds "Display" {
            "XF86MonBrightnessDown" = mkKeybinds {
              allow-when-locked = true;
              hotkey-overlay-title = "Decrease Brightness";
            } {spawn-sh = ["brightnessctl" "set" "10%-"];};

            "XF86MonBrightnessUp" = mkKeybinds {
              allow-when-locked = true;
              hotkey-overlay-title = "Increase Brightness";
            } {spawn-sh = ["brightnessctl" "set" "10%+"];};
          }
        ))

        (mkCategorizedKeybinds "Workspaces" (lib.recursiveUpdate
          (mkWorkspaceBinds "Mod" "focus-workspace")
          {
            "Mod+Backspace".focus-workspace-previous = [];
          }))

        (mkCategorizedKeybinds "Columns" {
          "Mod+Comma".focus-column-first = [];
          "Mod+H".focus-column-left = [];
          "Mod+L".focus-column-right = [];
          "Mod+Period".focus-column-last = [];

          "Mod+R" = mkKeybinds {hotkey-overlay-title = "Resize Column";} {
            spawn-sh = [
              (getExe (mkMenu [
                {
                  key = "d";
                  cmd = "niri msg action set-column-width 50%";
                  desc = "1/2 width";
                }
                {
                  key = "f";
                  cmd = "niri msg action set-column-width 67%";
                  desc = "2/3 width";
                }
                {
                  key = "g";
                  cmd = "niri msg action set-column-width 100%";
                  desc = "Full width";
                }
                {
                  key = "s";
                  cmd = "niri msg action set-column-width 33%";
                  desc = "1/3 width";
                }
              ]))
            ];
          };

          "Mod+S".toggle-column-tabbed-display = [];

          "Mod+W" = mkKeybinds {hotkey-overlay-title = "Equalize Columns";} {
            spawn-sh = [(getExe equalizeColumns)];
          };
        })

        (mkCategorizedKeybinds "Move Columns" (lib.recursiveUpdate
          (mkWorkspaceBinds "Mod+Shift" "move-column-to-workspace")
          {
            "Mod+Shift+Comma".move-column-to-first = [];
            "Mod+Shift+H".move-column-left = [];
            "Mod+Shift+L".move-column-right = [];
            "Mod+Shift+Period".move-column-to-last = [];
          }))

        (mkCategorizedKeybinds "Windows" {
          "Mod+Ctrl+H".consume-or-expel-window-left = [];
          "Mod+Ctrl+L".consume-or-expel-window-right = [];
          "Mod+F".fullscreen-window = [];
          "Mod+J".focus-window-down = [];
          "Mod+K".focus-window-up = [];
          "Mod+M".maximize-window-to-edges = [];
          "Mod+MouseForward".toggle-window-floating = [];
          "Mod+Q".close-window = [];
          "Mod+Shift+F".toggle-windowed-fullscreen = [];
          "Mod+Shift+J".move-window-down = [];
          "Mod+Shift+K".move-window-up = [];

          "Mod+Shift+Q" = mkKeybinds {hotkey-overlay-title = "Close Window (Pick)";} {
            spawn = ["niri msg action close-window --id {{id}}" "niri-window-picker-menu"];
          };

          "Mod+Shift+Space".toggle-window-floating = [];
          "Mod+Space".switch-focus-between-floating-and-tiling = [];
          "Mod+Tab".toggle-overview = [];
        })

        (mkCategorizedKeybinds "Tools" {
          "Mod+O" = mkKeybinds {hotkey-overlay-title = "Cast Window (Pick)";} {
            spawn = ["bash" "-c" "niri msg action set-dynamic-cast-window --id $(niri msg --json pick-window | jq .id)"];
          };
        })

        (mkCategorizedKeybinds "System" {
          "Mod+Shift+E" = mkKeybinds {hotkey-overlay-title = "Exit Session";} {
            quit._props.skip-confirmation = true;
          };
        })
      ];
    };

    lib.niri = {
      # The Noctalia cheatsheet reads these comments as category boundaries.
      # Reset afterwards so later uncategorized bindings retain auto-detection.
      mkCategorizedKeybinds = category: binds: let
        label = lib.replaceStrings ["\"" "\n" "\r"] ["'" " " " "] category;
      in
        assert label != "";
          lib.concatLists [
            [
              {"// #\"${label}\"" = {};}
            ]
            (lib.mapAttrsToList (name: value: {${name} = value;}) binds)
            [
              {"// #\" \"" = {};}
            ]
          ];

      mkKeybinds = props: options:
        lib.mkMerge [
          options
          {_props = props;}
        ];
    };
  };
}
