{
  self,
  lib,
  ...
}: let
  inherit (lib) flatten optional;

  mkImports = pkgs: [
    (self.factory.fonts-defaults {inherit pkgs;})
    self.modules.generic.fonts-options
  ];

  mkFontPackages = config:
    flatten [
      (optional (config.font.emoji.package != null) config.font.emoji.package)
      (optional (config.font.monospace.package != null) config.font.monospace.package)
      (optional (config.font.sansSerif.package != null) config.font.sansSerif.package)
      (optional (config.font.serif.package != null) config.font.serif.package)
      config.font.extraPackages
    ];

  mkDefaultFonts = config: {
    emoji = [config.font.emoji.name];
    monospace = [config.font.monospace.name];
    sansSerif = [config.font.sansSerif.name];
    serif = [config.font.serif.name];
  };
in {
  flake.modules = {
    nixos.fonts = {
      config,
      pkgs,
      ...
    }: {
      imports = mkImports pkgs;

      fonts = {
        enableDefaultPackages = false;
        enableGhostscriptFonts = true;
        fontconfig.defaultFonts = mkDefaultFonts config;
        packages = mkFontPackages config;
      };
    };

    darwin.fonts = {
      config,
      pkgs,
      ...
    }: {
      imports = mkImports pkgs;
      fonts.packages = mkFontPackages config;
    };

    homeManager.fonts = {
      config,
      pkgs,
      ...
    }: {
      imports = mkImports pkgs;

      fonts.fontconfig = {
        enable = true;
        defaultFonts = mkDefaultFonts config;
      };

      home.packages = mkFontPackages config;
    };
  };
}
