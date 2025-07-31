{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) types mkIf;
  inherit (lib.internal) mkOpt mkBoolOpt mkSubmoduleOpt;
  cfg = config.system.fonts;
in {
  options.system.fonts = {
    enable = mkBoolOpt false "Whether to enable custom fonts.";
    mono = mkSubmoduleOpt {
      name = mkOpt (types.nullOr types.str) null "Name of the system Mono font.";
      package = mkOpt (types.nullOr types.package) null "Package containing the monospace font";
    };
  };

  config = mkIf cfg.enable {
    system.fonts.mono = {
      name = "GeistMono Nerd Font Mono";
      package = pkgs.nerd-fonts.geist-mono;
    };
  };
}
