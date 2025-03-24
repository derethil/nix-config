{pkgs, ...}: {
  imports = [
    ./global
    ./features/cli
    ./features/games
    ./features/desktop/hyprland
  ];
}
