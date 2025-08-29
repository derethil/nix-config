{
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.internal) mkBoolOpt;
  cfg = config.system.hotkeys;
in {
  options.system.hotkeys = {
    enable = mkBoolOpt false "Whether or not to configure macOS keyboard shortcuts.";
    windows.enable = mkBoolOpt true "Whether or not to enable macOS window management keyboard shortcuts.";
    spotlight.enable = mkBoolOpt false "Whether or not to change the macOS Spotlight keyboard shortcut.";
    inputSources.enable = mkBoolOpt false "Whether or not to disable the macOS input source keyboard shortcuts.";
  };

  config = mkIf cfg.enable {
    system = {
      keyboard = {
        enableKeyMapping = true;
        remapCapsLockToEscape = true;
      };

      defaults = {
        CustomUserPreferences = {
          "com.apple.symbolichotkeys" = lib.mkMerge [
            {
              "52".enabled = false; # Disable toggle dock autohide
            }

            (mkIf cfg.inputSources.enable {
              "60".enabled = false; # Disable next input source
              "61".enabled = false; # Disable previous input source
            })

            (mkIf cfg.spotlight.enable {
              # Spotlight [Command + /]
              "64" = {
                enabled = true;
                value = {
                  parameters = [47 44 1048576];
                  type = "standard";
                };
              };

              # Finder [Option + Command + /]
              "65" = {
                enabled = true;
                value = {
                  parameters = [47 44 1572864];
                  type = "standard";
                };
              };
            })

            (mkIf (!cfg.windows.enable) {
              # General
              "233".enabled = false;
              "235".enabled = false;
              "237".enabled = false;
              "238".enabled = false;
              "239".enabled = false;
              # Halves
              "240".enabled = false;
              "241".enabled = false;
              "242".enabled = false;
              "243".enabled = false;
              # Quarters
              "244".enabled = false;
              "245".enabled = false;
              "246".enabled = false;
              "247".enabled = false;
              # Arrange
              "248".enabled = false;
              "249".enabled = false;
              "250".enabled = false;
              "251".enabled = false;
              "256".enabled = false;
              # Full Screen Tile
              "257".enabled = false;
              "258".enabled = false;
            })
          ];
        };
      };
    };
  };
}
