{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.glace.system.fonts;
in {
  config = mkIf cfg.enable {
    fonts = {
      enableGhostscriptFonts = true;
      enableDefaultFonts = false;

      fontconfig.defaultFonts = {
        serif = mkIf (cfg.default.serif.name != null) [cfg.default.serif.name];
        sansSerif = mkIf (cfg.default.sansSerif.name != null) [cfg.default.sansSerif.name];
        monospace = mkIf (cfg.default.monospace.name != null) [cfg.default.monospace.name];
        emoji = mkIf (cfg.default.emoji.name != null) [cfg.default.emoji.name];
      };
    };
  };
}
