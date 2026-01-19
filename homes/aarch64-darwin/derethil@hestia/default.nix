{lib, ...}: let
  inherit (lib.glace) enabled disabled;
in {
  glace = {
    distro = "darwin";
    user = {
      userdirs = enabled;
    };
    apps = {
      terminals = {
        default = "alacritty";
        alacritty = enabled;
      };
      browsers = {
        firefox = enabled;
      };
      social = {
        discord = enabled;
        mattermost = disabled;
      };
      obsidian = enabled;
      spotify = enabled;
      bruno = enabled;
      gaming.prismlauncher = enabled;
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
      qemu = enabled;
      development = {
        devenv = enabled;
        aws-cli = enabled;
        git = enabled;
        jira-cli = enabled;
        neovim = enabled;
        claude-code = enabled;
        postgresql = enabled;
      };
      nix = {
        manix = enabled;
        nix-index = enabled;
        home-manager = enabled;
        cachix = enabled;
      };
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
  };

  home.stateVersion = "25.05";
}
