{lib, ...}: let
  inherit (lib) mkOption types;
in {
  flake.modules.homeManager.terminal-options = {
    key = "terminal-options";

    options.terminal = {
      commands = {
        base = mkOption {
          default = [];
          type = types.listOf types.str;
        };

        withTmux = mkOption {
          default = [];
          type = types.listOf types.str;
        };
      };

      desktopFiles = mkOption {
        default = [];
        description = "Ordered list of terminal desktop files for xdg-terminal-exec. First entry is the default.";
        type = types.listOf types.str;
      };
    };
  };
}
