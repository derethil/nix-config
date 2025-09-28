{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.system.fonts;
in {
  config = mkIf cfg.enable {
    fonts.fontconfig.enable = true;
  };
}

