{
  flake.modules.homeManager.niri = {pkgs, ...}: {
    home.packages = [pkgs.xwayland-satellite];
  };
}
