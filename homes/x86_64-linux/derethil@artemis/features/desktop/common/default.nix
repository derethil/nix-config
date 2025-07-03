{pkgs, ...}: {
  imports = [
    ./chromium.nix
    ./gtk.nix
  ];

  home.packages = with pkgs; [
    discord
    obs-studio
    obsidian
    spotify
    vesktop
  ];
}
