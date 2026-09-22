{
  flake.modules.homeManager.chromium = {
    lib,
    pkgs,
    ...
  }:
    lib.mkIf pkgs.stdenv.isLinux {
      programs.chromium = {
        enable = true;
        package = pkgs.chromium;
      };
    };
}
