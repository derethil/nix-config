{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) types;
  inherit (lib.internal) mkNullableOpt mkBoolOpt mkOpt;
in {
  options.system.fonts = with types; {
    enable = mkBoolOpt false "Whether to enable custom fonts.";
    mono = {
      name = mkNullableOpt str null "Name of the system Mono font.";
      package = mkNullableOpt package null "Package containing the monospace font";
      size = mkOpt int 12 "Default size for monospace font.";
      style = mkOpt str "SemiBold" "Default style for monospace font.";
    };
    extraFonts = mkOpt (listOf package) [] "Additional font packages to install.";
  };

  config.system.fonts = {
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
}
