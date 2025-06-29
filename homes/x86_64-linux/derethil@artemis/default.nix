{
  imports = [
    ./global
    ./features/cli
    ./features/games
    ./features/desktop/hyprland
    ./features/work
  ];

  apps = {
    firefox.enable = true;
    foot.enable = true;
  };
  tools = {
    nixgl.enable = true;
  };
  hardware = {
    nvidia.enable = true;
  };

  home.stateVersion = "25.05";
}
