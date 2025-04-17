{pkgs, ...}: {
  home.packages = with pkgs; [
    gdlauncher-carbon
    heroic
    r2modman
  ];
}
