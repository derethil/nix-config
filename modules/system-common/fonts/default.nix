{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.glace.system.fonts;
in {
  config = mkIf cfg.enable {
    fonts.packages = lib.flatten [
      (lib.optional (cfg.mono.package != null) cfg.mono.package)
      cfg.extraFonts
    ];
  };
}