{
  flake.modules.homeManager.vlc = {
    pkgs,
    lib,
    ...
  }:
    lib.mkIf pkgs.stdenv.isLinux {
      home.packages = [pkgs.vlc];
    };
}
