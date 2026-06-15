{lib, ...}: {
  flake.modules.homeManager.protonup-qt = {pkgs, ...}: {
    home.packages = lib.mkIf pkgs.stdenv.hostPlatform.isLinux [pkgs.protonup-qt];
  };
}
