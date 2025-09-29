{
  lib,
  config,
  ...
}: let
  inherit (lib.glace) enabled enabled' disabled;
in {
  glace = {
    user = {
      name = "derethil";
      userdirs = enabled;
    };
    apps = {
      mattermost = enabled;
      steam = enabled;
      stremio = enabled;
    };
    desktop = {
      night-shift = enabled;
      mediamate = enabled;
      homerow = enabled;
    };
    tools = {
      nh = enabled;
      reset-launch-services = enabled;
    };
    system = {
      fonts = enabled;
      locate = enabled;
      settings = enabled' {
        dock-apps = [
          {app = "/Users/${config.glace.user.name}/Applications/Home Manager Apps/Alacritty.app";}
          {app = "/Users/${config.glace.user.name}/Applications/Home Manager Apps/Firefox.app";}
          {app = "/System/Applications/Messages.app";}
          {app = "/Applications/Mattermost.app";}
          {app = "/Users/${config.glace.user.name}/Applications/Home Manager Apps/Discord.app";}
          {app = "/Users/${config.glace.user.name}/Applications/Home Manager Apps/Bruno.app";}
          {app = "/Users/${config.glace.user.name}/Applications/Home Manager Apps/Obsidian.app";}
          {app = "/Users/${config.glace.user.name}/Applications/Home Manager Apps/Spotify.app";}
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
    nix = {
      config = enabled' {
        garbageCollection = enabled;
      };
    };
  };

  system.stateVersion = 5;
}
