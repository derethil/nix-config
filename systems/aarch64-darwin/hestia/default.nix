{lib, ...}: let
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
        {app = "~/Applications/Home Manager Trampolines/Alacritty.app";}
        {app = "~/Applications/Home Manager Trampolines/Firefox.app";}
        {spacer = {small = true;};}
        {app = "/System/Applications/Messages.app";}
        {app = "~/Applications/Home Manager Trampolines/Discord.app";}
        {spacer = {small = true;};}
        {app = "~/Applications/Home Manager Trampolines/Insomnia.app";}
        {app = "~/Applications/Home Manager Trampolines/Obsidian.app";}
        {spacer = {small = true;};}
        {app = "~/Applications/Home Manager Trampolines/Spotify.app";}
        {app = "/Applications/Stremio.app";}
        {app = "/Applications/GDLauncher.app";}
      ];
    };
  };
  cli = {
    fish = enabled;
  };
  tools = {
    darwin-option = true;
  };

  system.stateVersion = 5;
}
