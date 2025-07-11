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
    gtk-icon-browser = enabled;
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
    hyprland = {
      enable = true;
      withPackage = false;
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
