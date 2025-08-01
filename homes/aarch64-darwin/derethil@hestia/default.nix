{lib, ...}:
with lib;
with internal; {
  distro = "darwin";
  user = {
    location.latitude = 39.7392;
    location.longitude = -104.9903;
    userdirs = enabled;
  };
  apps = {
    alacritty = enabled;
    firefox = enabled;
    discord = enabled;
    obsidian = enabled;
    spotify = enabled;
    insomnia = enabled;
    mattermost = disabled;
  };
  languages = {
    golang = enabled;
  };
  desktop = {
    xdg = enabled;
    addons = {
      wallpapers = enabled;
    };
  };
  tools = {
    manix = enabled;
    aws-cli = enabled;
    git = enabled;
    jira-cli = enabled;
    neovim = enabled;
    claude-code = enabled;
  };
  cli = {
    fish = enabled;
    direnv = enabled;
    zoxide = enabled;
    starship = enabled;
    tmux = enabled;
    misc = enabled;
  };
  system = {
    fonts = enabled;
  };

  home.stateVersion = "25.05";
}
