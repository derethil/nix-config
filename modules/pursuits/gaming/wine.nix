{
  flake.modules.nixos.wine = {pkgs, ...}: {
    environment.systemPackages = [
      pkgs.wineWow64Packages.staging
      pkgs.winetricks
    ];
  };

  flake.modules.homeManager.wine = {
    pkgs,
    lib,
    ...
  }: {
    home.packages = lib.mkIf pkgs.stdenv.hostPlatform.isLinux [
      pkgs.wineWow64Packages.staging
      pkgs.winetricks
    ];
  };
}
