{self, lib, ...}: {
  flake.modules.darwin.hotkeys = {pkgs, config, ...}: {
    imports = [self.modules.darwin.skhd];

    # TODO: derive from terminal.commands.withTmux (HM option) instead of hardcoding
    services.skhd.skhdConfig = "cmd - return : open -na ${pkgs.alacritty}/Applications/Alacritty.app --args -e ${pkgs.tmux}/bin/tmux new-session -As base";

    system.keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = true;
    };

    system.defaults.CustomUserPreferences."com.apple.symbolichotkeys" = lib.mkMerge [
      {
        "52".enabled = false; # Disable toggle dock autohide

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
      }

      (lib.mkIf config.services.paneru.enable {
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
}
