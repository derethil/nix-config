{...}: {
  flake.modules.homeManager.r2modman = {pkgs, ...}: {
    home.packages = [pkgs.r2modman];
  };
}
