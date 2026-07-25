{
  flake.modules.homeManager.qalculate = {pkgs, ...}: {
    home.packages = [
      pkgs.libqalculate
      pkgs.qalculate-gtk
    ];
  };
}
