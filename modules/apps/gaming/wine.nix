{
  flake.modules = {
    nixos.wine = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.wineWow64Packages.staging
        pkgs.winetricks
      ];
    };

    homeManager.wine = {
      lib,
      pkgs,
      ...
    }: {
      home.packages = lib.mkIf pkgs.stdenv.hostPlatform.isLinux [
        pkgs.wineWow64Packages.staging
        pkgs.winetricks
      ];
    };
  };
}
