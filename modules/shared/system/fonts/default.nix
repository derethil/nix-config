{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) types mkIf;
  inherit (lib.internal) mkNullableOpt mkBoolOpt mkSubmoduleOpt;
  cfg = config.system.fonts;
in {
  options.system.fonts = {
    enable = mkBoolOpt false "Whether to enable custom fonts.";
    mono = mkSubmoduleOpt "Configuration for the default system monospace font." {
      name = mkNullableOpt types.str null "Name of the system Mono font.";
      package = mkNullableOpt types.package null "Package containing the monospace font";
    };
  };

  config = mkIf cfg.enable {
    system.fonts.mono = {
      name = "GeistMono Nerd Font Mono";
      package = pkgs.nerd-fonts.geist-mono;
    };
  };
}
