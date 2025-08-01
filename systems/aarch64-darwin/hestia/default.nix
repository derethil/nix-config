{
  lib,
  config,
  ...
}: let
  inherit (lib.internal) enabled enabled';
in {
  user = {
    name = "derethil";
    userdirs = enabled;
  };
  system = {
    fonts = enabled;
    nix = enabled;
    settings = enabled' {
      dock-apps = [
        {app = "/Users/${config.user.name}/Applications/Home Manager Apps/Alacritty.app";}
        {app = "/Users/${config.user.name}/Applications/Home Manager Apps/Firefox.app";}
        {app = "/System/Applications/Messages.app";}
        {app = "/Users/${config.user.name}/Applications/Home Manager Apps/Discord.app";}
        {app = "/Users/${config.user.name}/Applications/Home Manager Apps/Insomnia.app";}
        {app = "/Users/${config.user.name}/Applications/Home Manager Apps/Obsidian.app";}
        {app = "/Users/${config.user.name}/Applications/Home Manager Apps/Spotify.app";}
        {app = "/Applications/Stremio.app";}
        {app = "/Applications/GDLauncher.app";}
      ];
    };
  };
  cli = {
    fish = enabled;
  };

  system.stateVersion = 5;
}
