{
  flake.modules.homeManager.pinta = {
    pkgs,
    lib,
    ...
  }: {
    home.packages = lib.mkIf pkgs.stdenv.hostPlatform.isLinux [pkgs.pinta];
  };
}
