{
  flake.modules.homeManager.vlc = {
    lib,
    pkgs,
    ...
  }:
    lib.mkIf pkgs.stdenv.isLinux {
      home.packages = [pkgs.vlc];
    };
}
