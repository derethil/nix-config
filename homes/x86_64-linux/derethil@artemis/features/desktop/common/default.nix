{pkgs, ...}: {
  imports = [
    ./chromium.nix
    ./gtk.nix
    ./wayland
  ];

  home.packages = with pkgs; [
    discord
    obs-studio
    obsidian
    spotify
    vesktop
  ];
}
