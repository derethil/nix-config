{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) types;
  inherit (lib.glace) mkNullableOpt mkBoolOpt mkOpt;
in {
  options.glace.system.fonts = with types; let
    fontOptions = type: {
      name = mkNullableOpt str null "Name of the default ${type} font.";
      package = mkNullableOpt package null "Package containing the default ${type} font";
      size = mkOpt int 12 "Default size for ${type} font.";
      style = mkOpt str "Regular" "Default style for ${type} font.";
    };
  in {
    enable = mkBoolOpt false "Whether to enable custom fonts.";
    extraFonts = mkOpt (listOf package) [] "Additional font packages to install.";
    default = {
      serif = fontOptions "serif";
      sansSerif = fontOptions "sans-serif";
      monospace = fontOptions "monospace";
      emoji = {inherit (fontOptions "emoji") name package;};
    };
  };

  config.glace.system.fonts = {
    default = {
      sans = {
        name = "Inter Display";
        package = pkgs.inter;
      };
      sansSerif = {
        name = "Noto Sans";
        package = pkgs.noto-fonts;
      };
      monospace = {
        name = "GeistMono Nerd Font Mono";
        package = pkgs.nerd-fonts.geist-mono;
        style = "SemiBold";
      };
      emoji = {
        name = "Noto Color Emoji";
        package = pkgs.noto-fonts-color-emoji;
      };
    };
    extraFonts = with pkgs; [
      noto-fonts-emoji
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
    ];
  };
}
