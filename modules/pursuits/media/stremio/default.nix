{
  perSystem = {
    pkgs,
    system,
    lib,
    ...
  }:
    lib.optionalAttrs (system == "aarch64-darwin") {
      packages.stremio = pkgs.callPackage ./_pkg-darwin.nix {};
    };

  flake.modules.homeManager.stremio = {pkgs, ...}: {
    home.packages = [
      (
        if pkgs.stdenv.hostPlatform.isDarwin
        then pkgs.internal.stremio
        else pkgs.stremio-linux-shell
      )
    ];
  };
}
