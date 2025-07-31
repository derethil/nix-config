{lib, ...}:
with lib;
with internal; {
  distro = "darwin";
  user = {
    location.latitude = 39.7392;
    location.longitude = -104.9903;
  };
  apps = {
    foot = disabled;
    alacritty = enabled;
    firefox = enabled;
    gtk-icon-browser = disabled;
    chromium = enabled;
    discord = enabled;
    vesktop = disabled;
    obsidian = enabled;
    spotify = enabled;
    insomnia = enabled;
    mattermost = enabled;
    heroic = disabled;
    r2modman = disabled;
  };
  languages = {
    golang = enabled;
  };
  desktop = {
    xdg = enabled;
    glace-shell = disabled;
  };
  tools = {
    manix = enabled;
    aws-cli = enabled;
    git = enabled;
    jira-cli = enabled;
    neovim = enabled;
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

  home.stateVersion = "25.05";
}
