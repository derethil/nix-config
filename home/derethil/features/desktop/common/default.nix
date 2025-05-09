{pkgs, ...}: {
  imports = [
    ./chromium.nix
    ./firefox
    ./gtk.nix
    ./nixgl.nix
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
