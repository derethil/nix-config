{
  flake.modules.homeManager.chromium = {
    pkgs,
    lib,
    ...
  }:
    lib.mkIf pkgs.stdenv.isLinux {
      programs.chromium = {
        enable = true;
        package = pkgs.chromium;
      };
    };
}
