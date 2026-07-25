{lib, ...}: let
  inherit (lib) mkOption types;
in {
  flake.modules.generic.shell-options = {
    options.shell = {
      abbreviations = mkOption {
        default = {};
        type = types.attrsOf types.str;
      };

      aliases = mkOption {
        default = {};
        type = types.attrsOf types.str;
      };

      defaultShell = mkOption {
        type = types.package;
      };
    };
  };
}
