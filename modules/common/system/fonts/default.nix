{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) types mkIf;
  inherit (lib.internal) mkNullableOpt mkBoolOpt mkOpt;
  cfg = config.system.fonts;
in {
  options.system.fonts = with types; {
    enable = mkBoolOpt false "Whether to enable custom fonts.";
    mono = {
      name = mkNullableOpt str null "Name of the system Mono font.";
      package = mkNullableOpt package null "Package containing the monospace font";
    };
    extraFonts = mkOpt (listOf package) [] "Additional font packages to install.";
  };

  config = mkIf cfg.enable {
    system.fonts = {
      mono = {
        name = "GeistMono Nerd Font Mono";
        package = pkgs.nerd-fonts.geist-mono;
      };
      extraFonts = with pkgs; [
        noto-fonts
        noto-fonts-emoji
        noto-fonts-color-emoji
        noto-fonts-cjk-sans
        noto-fonts-cjk-serif
      ];
    };
  };
}
