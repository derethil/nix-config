{pkgs, ...}: {
  imports = [
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
