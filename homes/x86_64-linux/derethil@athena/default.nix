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
      firefox = enabled;
      chromium = enabled;
      gtk-icon-browser = enabled;
      discord = enabled;
      vesktop = disabled;
      stremio = disabled;
      obs = enabled;
      obsidian = enabled;
      spotify = enabled;
      insomnia = enabled;
      mattermost = enabled;
      gdlauncher = enabled;
      heroic = disabled;
      r2modman = enabled;
    };
    desktop = {
      hyprland = enabled;
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
      hyprpicker = enabled;
      hyprshot = enabled;
      hyprprop = enabled;
    };
    services = {
      openssh = enabled;
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
    system = {
      fonts = enabled;
    };
    hardware = {
      displays = [
        {
          name = "Ultrawide";
          primary = true;
          port = "DP-3";
          resolution = "3440x1440";
          framerate = 144;
          vrr = 1;
          wallpaper = "fuji-bird.jpeg";
        }
      ];
    };
  };

  home.stateVersion = "25.05";
}
