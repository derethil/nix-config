{
  config,
  lib,
  ...
}: let
  cfg = config.system.fonts;
in {
  config = lib.mkIf cfg.enable {
    fonts.packages = lib.flatten [
      (lib.optional (cfg.mono.package != null) cfg.mono.package)
      cfg.extraFonts
    ];
  };
}