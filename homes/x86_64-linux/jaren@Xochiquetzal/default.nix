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
    alacritty = enabled;
    firefox = enabled;
    gtk-icon-browser = enabled;
    chromium = enabled;
    discord = enabled;
    vesktop = enabled;
    obs = enabled;
    obsidian = enabled;
    spotify = enabled;
    stremio = enabled;
    insomnia = enabled;
    mattermost = enabled;
    gdlauncher = enabled;
    heroic = disabled;
    r2modman = disabled;
  };
  languages = {
    golang = enabled;
  };
  desktop = {
    xdg = enabled;
    glace-shell = enabled;
    hyprland = {
      enable = true;
      smallerLoneWindows.enable = false;
    };
    addons = {
      wlsunset = enabled;
      cliphist = enabled;
      gtk = enabled;
      wallpapers = enabled;
      hyprpaper = enabled;
    };
  };
  tools = {
    manix = enabled;
    aws-cli = enabled;
    git = enabled;
    jira-cli = enabled;
    hyprprop = enabled;
    hyprshot = enabled;
    hyprpicker = enabled;
    neovim = enabled;
    sober = enabled;
  };
  cli = {
    fish = enabled;
    trashy = enabled;
    direnv = enabled;
    zoxide = enabled;
    starship = enabled;
    tmux = enabled;
    misc = enabled;
    wl-clipboard = enabled;
    chafa = enabled;
  };
  hardware = {
    nvidia = disabled;
    displays = [
      {
        name = "Laptop";
        primary = true;
        port = "eDP-1";
        resolution = "1920x1080";
        framerate = 60;
        vrr = 1;
        wallpaper = "fuji-bird.jpeg";
      }
    ];
  };

  home.stateVersion = "25.05";
}
