{lib, ...}: let
  inherit (lib.glace) enabled disabled;
in {
  glace = {
    user = {
      location.latitude = 39.7392;
      location.longitude = -104.9903;
      userdirs = enabled;
    };
    apps = {
      foot = enabled;
      gtk-icon-browser = enabled;
      stremio = enabled;
      obs = enabled;
      obsidian = enabled;
      spotify = enabled;
      bruno = enabled;
      browsers = {
        firefox = enabled;
        chromium = enabled;
      };
      gaming = {
        gdlauncher = enabled;
        prismlauncher = disabled;
        heroic = disabled;
        r2modman = enabled;
      };
      social = {
        discord = disabled;
        vesktop = enabled;
        mattermost = enabled;
      };
    };
    desktop = {
      hyprland = disabled;
      niri = enabled;
      dank-material-shell = enabled;
      xdg = enabled;
      addons = {
        wlsunset = enabled;
        cliphist = enabled;
        gtk = enabled;
        wallpapers = enabled;
      };
    };
    tools = {
      gaming = {
        protonup-qt = enabled;
        lossless-scaling = enabled;
        mangohud = enabled;
      };
      desktop = {
        hyprpicker = enabled;
        hyprshot = disabled;
      };
      nix = {
        manix = enabled;
        nix-index = enabled;
        home-manager = enabled;
      };
      development = {
        devenv = enabled;
        git = enabled;
        jira-cli = enabled;
        claude-code = enabled;
        postgresql = enabled;
        aws-cli = enabled;
        neovim = enabled;
      };
    };
    services = {
      openssh = enabled;
    };
    cli = {
      fish = enabled;
      gtrash = enabled;
      direnv = enabled;
      zoxide = enabled;
      starship = enabled;
      tmux = enabled;
      misc = enabled;
      wl-clipboard = enabled;
      chafa = enabled;
    };
    system = {
      fonts = enabled;
    };
    hardware = {
      displays = [
        {
          name = "Ultrawide";
          primary = true;
          port = "DP-3";
          resolution = {
            width = 3440;
            height = 1440;
          };
          framerate = 160;
          vrr = true;
          wallpaper = "fuji-bird.jpeg";
        }
      ];
    };
  };

  home.stateVersion = "25.05";
}
