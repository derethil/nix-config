{lib, ...}: let
  inherit (lib) mkOption types;
in {
  flake.modules.generic.shell-options = {
    options.shell = {
      defaultShell = mkOption {
        type = types.package;
      };
      aliases = mkOption {
        type = types.attrsOf types.str;
        default = {};
      };
      abbreviations = mkOption {
        type = types.attrsOf types.str;
        default = {};
      };
    };
  };
}
