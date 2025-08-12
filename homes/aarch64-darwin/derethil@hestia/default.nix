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
    bruno = enabled;
    mattermost = disabled;
  };
  languages = {
    golang = enabled;
  };
  desktop = {
    aerospace = enabled;
    xdg = enabled;
    addons = {
      wallpapers = enabled;
      osascript-wallpaper = enabled;
    };
  };
  tools = {
    devenv = enabled;
    manix = enabled;
    aws-cli = enabled;
    git = enabled;
    jira-cli = enabled;
    neovim = enabled;
    claude-code = enabled;
    nix-index = enabled;
    postgresql = enabled;
    home-manager = enabled;
  };
  cli = {
    fish = enabled;
    direnv = enabled;
    zoxide = enabled;
    starship = enabled;
    tmux = enabled;
    misc = enabled;
    trash-cli = enabled;
  };
  hardware.displays = [
    {
      wallpaper = "fuji-bird.jpeg";
    }
  ];

  system = {
    fonts = enabled;
  };

  home.stateVersion = "25.05";
}
