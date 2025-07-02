{lib, ...}:
with lib;
with internal; let
  pc-path = "../derethil@artemis";
in {
  imports = [
    ./${pc-path}/global
    ./${pc-path}/features/games
    ./${pc-path}/features/desktop/hyprland
    ./${pc-path}/features/work
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
    misc = enabled;
  };
  hardware = {
    nvidia = disabled;
  };

  home.stateVersion = "25.05";
}
