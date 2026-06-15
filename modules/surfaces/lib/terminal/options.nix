{lib, ...}: let
  inherit (lib) mkOption types;
in {
  flake.modules.homeManager.terminal-options = {
    key = "terminal-options";
    options.terminal = {
      desktopFiles = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "Ordered list of terminal desktop files for xdg-terminal-exec. First entry is the default.";
      };
      commands = {
        base = mkOption {
          type = types.listOf types.str;
          default = [];
        };
        withTmux = mkOption {
          type = types.listOf types.str;
          default = [];
        };
      };
    };
  };
}
