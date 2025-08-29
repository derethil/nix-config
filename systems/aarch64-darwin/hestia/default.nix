{
  lib,
  config,
  ...
}: let
  inherit (lib.internal) enabled enabled' disabled;
in {
  user = {
    name = "derethil";
    userdirs = enabled;
  };
  apps = {
    mattermost = enabled;
    steam = enabled;
    stremio = enabled;
    mediamate = enabled;
  };
  desktop = {
    night-shift = enabled;
  };
  tools = {
    nh = enabled;
  };
  system = {
    fonts = enabled;
    nix = enabled;
    locate = enabled;
    settings = enabled' {
      dock-apps = [
        {app = "/Users/${config.user.name}/Applications/Home Manager Apps/Alacritty.app";}
        {app = "/Users/${config.user.name}/Applications/Home Manager Apps/Firefox.app";}
        {app = "/System/Applications/Messages.app";}
        {app = "/Applications/Mattermost.app";}
        {app = "/Users/${config.user.name}/Applications/Home Manager Apps/Discord.app";}
        {app = "/Users/${config.user.name}/Applications/Home Manager Apps/Bruno.app";}
        {app = "/Users/${config.user.name}/Applications/Home Manager Apps/Obsidian.app";}
        {app = "/Users/${config.user.name}/Applications/Home Manager Apps/Spotify.app";}
        {app = "/Applications/Stremio.app";}
        {app = "/Applications/GDLauncher.app";}
        {app = "/Applications/Steam.app";}
      ];
    };
    hotkeys = enabled' {
      windows = disabled;
      spotlight = enabled;
      inputSources = disabled;
    };
  };
  cli = {
    fish = enabled;
  };

  system.stateVersion = 5;
}
