{
  flake.modules.homeManager.qalculate = {pkgs, ...}: {
    home.packages = [
      pkgs.qalculate-gtk
      pkgs.libqalculate
    ];
  };
}
