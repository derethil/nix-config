{lib, ...}:
with lib;
with internal; {
  imports = [
    ./global
    ./features/games
    ./features/desktop/hyprland
    ./features/work
  ];

  apps = {
    firefox = enabled;
    foot = enabled;
  };
  tools = {
    nixgl = enabled;
    aws-cli = enabled;
    git = enabled;
    jira-cli = enabled;
  };
  cli = {
    fish = enabled;
    trashy = enabled;
    direnv = enabled;
    zoxide = enabled;
    starship = enabled;
    tmux = enabled;
  };
  hardware = {
    nvidia = enabled;
  };

  home.stateVersion = "25.05";
}
