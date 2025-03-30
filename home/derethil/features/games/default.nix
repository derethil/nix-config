{pkgs, ...}: {
  imports = [
    ./r2modman.nix
  ];

  home.packages = with pkgs; [
    gdlauncher-carbon
    heroic
  ];
}
