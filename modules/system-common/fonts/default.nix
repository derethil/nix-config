{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf optional flatten;
  cfg = config.glace.system.fonts;
in {
  config = mkIf cfg.enable {
    fonts = {
      packages = flatten [
        (optional (cfg.default.monospace.package != null) cfg.default.monospace.package)
        (optional (cfg.default.sansSerif.package != null) cfg.default.sansSerif.package)
        (optional (cfg.default.serif.package != null) cfg.default.serif.package)
        (optional (cfg.default.emoji.package != null) cfg.default.emoji.package)
        cfg.extraFonts
      ];
    };
  };
}
