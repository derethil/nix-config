{
  imports = [
    ./global
    ./features/cli
    ./features/games
    ./features/desktop/hyprland
    ./features/work
  ];

  home.stateVersion = "24.11";

  apps = {
    firefox.enable = true;
  };
  tools = {
    nixgl.enable = true;
  };
  hardware = {
    nvidia.enable = true;
  };
}
