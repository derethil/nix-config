{lib, ...}: let
  inherit (lib) mkOption types;

  fontOptions = type: {
    package = mkOption {
      default = null;
      description = "Package for the default ${type} font.";
      type = types.nullOr types.package;
    };

    name = mkOption {
      description = "Name of the default ${type} font.";
      type = types.str;
    };

    size = mkOption {
      default = 9;
      type = types.int;
    };

    style = mkOption {
      default = "Regular";
      type = types.str;
    };
  };
in {
  flake.modules.generic.fonts-options = {
    key = "fonts-options";

    options.font = {
      emoji = {
        inherit (fontOptions "emoji") name package;
      };

      extraPackages = mkOption {
        default = [];
        description = "Additional font packages to install.";
        type = types.listOf types.package;
      };

      monospace = fontOptions "monospace";
      sansSerif = fontOptions "sans-serif";
      serif = fontOptions "serif";
    };
  };
}
