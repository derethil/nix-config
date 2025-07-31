{
  config,
  lib,
  ...
}: let
  cfg = config.system.fonts;
in {
  config = lib.mkIf cfg.enable {
    fonts.packages = [
      cfg.mono.package
    ];
  };
}
