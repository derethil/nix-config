{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.glace.system.fonts;
in {
  config = mkIf cfg.enable {
    fonts.fontconfig.enable = true;
  };
}

