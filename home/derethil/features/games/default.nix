{pkgs, ...}: {
  home.packages = with pkgs; [
    gdlauncher-carbon
    heroic
  ];
}
