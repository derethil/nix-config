{lib, ...}: let
  inherit (lib) mkOption types;

  fontOptions = type: {
    name = mkOption {
      type = types.str;
      description = "Name of the default ${type} font.";
    };
    package = mkOption {
      type = types.nullOr types.package;
      default = null;
      description = "Package for the default ${type} font.";
    };
    size = mkOption {
      type = types.int;
      default = 9;
    };
    style = mkOption {
      type = types.str;
      default = "Regular";
    };
  };
in {
  flake.modules.generic.fonts-options = {
    key = "fonts-options";
    options.font = {
      serif = fontOptions "serif";
      sansSerif = fontOptions "sans-serif";
      monospace = fontOptions "monospace";
      emoji = {
        inherit (fontOptions "emoji") name package;
      };
      extraPackages = mkOption {
        type = types.listOf types.package;
        default = [];
        description = "Additional font packages to install.";
      };
    };
  };
}
