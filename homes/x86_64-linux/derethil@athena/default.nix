{lib, ...}: let
  inherit (lib.glace) enabled disabled;
in {
  glace = {
    user = {
      userdirs = enabled;
    };
    apps = {
      terminals = {
        default = "foot";
        foot = enabled;
        kitty = enabled;
      };
      stremio = enabled;
      obs = enabled;
      obsidian = enabled;
      spotify = enabled;
      bruno = enabled;
      vlc = enabled;
      qalculate = enabled;
      pinta = enabled;
      browsers = {
        firefox = enabled;
        chromium = enabled;
      };
      gaming = {
        gdlauncher = disabled;
        prismlauncher = enabled;
        heroic = disabled;
        melonloader = enabled;
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
        nix-inspect = enabled;
        nix-index = enabled;
        home-manager = enabled;
        cachix = enabled;
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
      openhue = enabled;
    };
    services = {
      openssh = enabled;
      easyeffects = enabled;
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
      yazi = enabled;
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
