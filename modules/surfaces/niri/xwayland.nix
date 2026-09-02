{
  flake.modules.homeManager.niri = {pkgs, ...}: let
    # 0.8.2 (3273a0f) breaks override-redirect popups on niri; Steam menus
    # close instantly. https://github.com/Supreeeme/xwayland-satellite/issues/468
    xwayland-satellite = pkgs.xwayland-satellite.overrideAttrs (_: rec {
      cargoDeps = pkgs.rustPlatform.importCargoLock {
        allowBuiltinFetchGit = true;
        lockFile = "${src}/Cargo.lock";
      };

      src = pkgs.fetchFromGitHub {
        hash = "sha256-BUE41HjLIGPjq3U8VXPjf8asH8GaMI7FYdgrIHKFMXA=";
        owner = "Supreeeme";
        repo = "xwayland-satellite";
        rev = "v${version}";
      };

      version = "0.8.1";
    });
  in {
    home.packages = [xwayland-satellite];
  };
}
