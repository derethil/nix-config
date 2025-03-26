{pkgs, ...}: {
  imports = [
    ./wayland
    ./firefox
    ./nixgl.nix
  ];

  home.packages = with pkgs; [
    spotify
    discord
    vesktop
    obsidian
    obs-studio
  ];
}
