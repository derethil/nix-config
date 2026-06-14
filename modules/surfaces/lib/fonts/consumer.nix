{
  self,
  lib,
  ...
}: let
  inherit (lib) optional flatten;

  mkImports = pkgs: [
    self.modules.generic.fonts-options
    (self.factory.fonts-defaults {inherit pkgs;})
  ];

  mkFontPackages = config:
    flatten [
      (optional (config.font.serif.package != null) config.font.serif.package)
      (optional (config.font.sansSerif.package != null) config.font.sansSerif.package)
      (optional (config.font.monospace.package != null) config.font.monospace.package)
      (optional (config.font.emoji.package != null) config.font.emoji.package)
      config.font.extraPackages
    ];

  mkDefaultFonts = config: {
    serif = [config.font.serif.name];
    sansSerif = [config.font.sansSerif.name];
    monospace = [config.font.monospace.name];
    emoji = [config.font.emoji.name];
  };
in {
  flake.modules.homeManager.fonts = {
    config,
    pkgs,
    ...
  }: {
    imports = mkImports pkgs;
    home.packages = mkFontPackages config;
    fonts.fontconfig = {
      enable = true;
      defaultFonts = mkDefaultFonts config;
    };
  };

  flake.modules.nixos.fonts = {
    config,
    pkgs,
    ...
  }: {
    imports = mkImports pkgs;
    fonts = {
      enableGhostscriptFonts = true;
      enableDefaultPackages = false;
      packages = mkFontPackages config;
      fontconfig.defaultFonts = mkDefaultFonts config;
    };
  };

  flake.modules.darwin.fonts = {
    config,
    pkgs,
    ...
  }: {
    imports = mkImports pkgs;
    fonts.packages = mkFontPackages config;
  };
}
