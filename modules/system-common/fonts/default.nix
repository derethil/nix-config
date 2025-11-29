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
      enableDefaultPackages = false;
      enableGhostscriptFonts = true;

      fontconfig.defaultFonts = {
        serif = mkIf (cfg.default.serif.name != null) [cfg.default.serif.name];
        sansSerif = mkIf (cfg.default.sansSerif.name != null) [cfg.default.sansSerif.name];
        monospace = mkIf (cfg.default.monospace.name != null) [cfg.default.monospace.name];
        emoji = mkIf (cfg.default.emoji.name != null) [cfg.default.emoji.name];
      };

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
