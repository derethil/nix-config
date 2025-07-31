{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) types mkIf;
  inherit (lib.internal) mkNullableOpt mkBoolOpt;
  cfg = config.system.fonts;
in {
  options.system.fonts = with types; {
    enable = mkBoolOpt false "Whether to enable custom fonts.";
    mono = {
      name = mkNullableOpt str null "Name of the system Mono font.";
      package = mkNullableOpt package null "Package containing the monospace font";
    };
  };

  config = mkIf cfg.enable {
    system.fonts.mono = {
      name = "GeistMono Nerd Font Mono";
      package = pkgs.nerd-fonts.geist-mono;
    };
  };
}
