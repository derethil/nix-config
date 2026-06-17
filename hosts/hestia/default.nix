{
  self,
  inputs,
  withSystem,
  ...
}: let
  inherit (self.lib) mergeModules;

  flakeRoot = "/Users/derethil/.config/nix-config";

  displays = [
    {
      name = "Built-in";
      port = "Built-in";
      primary = true;
      resolution = {
        width = 3024;
        height = 1964;
      };
      framerate = 60;
      wallpaper = "fuji-bird.jpeg";
    }
  ];
in {
  # HOST CONFIGURATION

  flake.modules.darwin.hestia = {
    imports = with (mergeModules self.modules.generic self.modules.darwin); [
      # Framework
      user-derethil

      # Baseline
      foundation
      bridges

      # Desktop
      darwin-surfaces
      mediamate

      # Pursuits
      development
      comms-work
      lightweight-gaming
    ];

    internal = {
      inherit flakeRoot;

      dock.apps = let
        hm = name: "/Users/derethil/Applications/Home Manager Trampolines/${name}.app";
      in [
        {app = hm "Alacritty";}
        {app = hm "Firefox";}
        {app = "/System/Applications/Messages.app";}
        {app = "/Applications/Mattermost.app";}
        {app = hm "Discord";}
        {app = hm "Bruno";}
        {app = hm "Obsidian";}
        {app = hm "Spotify";}
        {app = hm "Stremio";}
        {app = hm "PrismLauncher";}
        {app = "/Applications/Steam.app";}
      ];
    };

    networking.hostName = "hestia";
    system.stateVersion = 5;
  };

  # HOME MANAGER CONFIGURATION

  flake.modules.homeManager.hestia-derethil = {
    imports = with self.modules.homeManager; [
      # Baseline
      foundation

      # Compositor
      paneru

      # Terminals
      alacritty

      # Surfaces
      wallpaper
      mac-app-util
      reset-launch-services

      # Pursuits
      browsers
      comms-work
      development
      lightweight-gaming
      media
      utilities
    ];

    internal = {
      inherit flakeRoot displays;
    };

    home.stateVersion = "25.05";
  };

  # HOST DEFINITION

  flake.darwinConfigurations.hestia = inputs.nix-darwin.lib.darwinSystem {
    system = "aarch64-darwin";
    pkgs = withSystem "aarch64-darwin" ({pkgs, ...}: pkgs);
    modules = [
      self.modules.darwin.hestia
      self.modules.darwin.home-manager
      inputs.home-manager.darwinModules.home-manager
      {home-manager.users.derethil = self.modules.homeManager.hestia-derethil;}
    ];
  };

  # HOME MANAGER DEFINITION

  flake.homeConfigurations."derethil@hestia" = withSystem "aarch64-darwin" ({pkgs, ...}:
    inputs.home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = {inherit self inputs;};
      modules = [
        self.modules.homeManager.home-manager
        self.modules.homeManager.hestia-derethil
        self.modules.homeManager.user-derethil
      ];
    });
}
