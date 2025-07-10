{lib, ...}:
with lib;
with internal; {
  distro = "arch";
  user = {
    location.latitude = 39.7392;
    location.longitude = -104.9903;
  };
  apps = {
    foot = enabled;
    firefox = enabled;
    chromium = enabled;
    discord = enabled;
    vesktop = enabled;
    obs = enabled;
    obsidian = enabled;
    spotify = enabled;
    insomnia = enabled;
    mattermost = enabled;
    gdlauncher = disabled;
    heroic = disabled;
    r2modman = disabled;
  };
  desktop = {
    hyprland = disabled;
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
    nvidia = disabled;
  };

  home.stateVersion = "25.05";
}
