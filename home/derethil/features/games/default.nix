{pkgs, ...}: {
  imports = [
    ./steam.nix
  ];

  home.packages = with pkgs; [
    gdlauncher-carbon
    heroic
  ];
}
