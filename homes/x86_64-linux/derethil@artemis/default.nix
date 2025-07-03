{lib, ...}:
with lib;
with internal; {
  imports = [
    ./global
    ./features/games
  ];

  user = {
    location.latitude = 39.7392;
    location.longitude = -104.9903;
  };
  apps = {
    firefox = enabled;
    chromium = enabled;
    discord = enabled;
    obs = enabled;
    obsidian = enabled;
    spotify = enabled;
    vesktop = enabled;
    foot = enabled;
    insomnia = enabled;
    mattermost = enabled;
  };
  desktop = {
    addons = {
      wlsunset = enabled;
      gtk = enabled;
    };
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
    nvidia = enabled;
  };

  home.stateVersion = "25.05";
}
