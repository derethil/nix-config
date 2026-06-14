{lib, ...}: let
  inherit (lib) mkOption types;
in {
  flake.modules.generic.shell-options = {
    options.shell = {
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
