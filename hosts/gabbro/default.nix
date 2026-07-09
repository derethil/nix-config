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

  flake.modules.darwin.gabbro = {pkgs, ...}: {
    imports = with (mergeModules self.modules.generic self.modules.darwin); [
      # Framework
      user-derethil

      # Baseline
      foundation
      bridges

      # Desktop
      paneru

      # Pursuits
      development
      comms-work
      lightweight-gaming
    ];

    internal = {
      inherit flakeRoot;

      dock.apps = [
        {app = "${pkgs.alacritty}/Applications/Alacritty.app";}
        {app = "${pkgs.firefox}/Applications/Firefox.app";}
        {app = "/System/Applications/Messages.app";}
        {app = "/Applications/Mattermost.app";}
        {app = "/Applications/Discord.app";}
        {app = "${pkgs.bruno}/Applications/Bruno.app";}
        {app = "${pkgs.obsidian}/Applications/Obsidian.app";}
        {app = "${pkgs.spotify}/Applications/Spotify.app";}
        {app = "${pkgs.internal.stremio}/Applications/Stremio.app";}
        {app = "${pkgs.prismlauncher}/Applications/PrismLauncher.app";}
        {app = "/Applications/Steam.app";}
      ];
    };

    networking.hostName = "gabbro";
    system.stateVersion = 5;
  };

  # HOME MANAGER CONFIGURATION

  flake.modules.homeManager.gabbro-derethil = {
    imports = with self.modules.homeManager; [
      # Baseline
      foundation

      # Terminals
      alacritty

      # Surfaces
      mac-app-util
      paneru

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

  flake.darwinConfigurations.gabbro = inputs.nix-darwin.lib.darwinSystem {
    system = "aarch64-darwin";
    pkgs = withSystem "aarch64-darwin" ({pkgs, ...}: pkgs);
    modules = [
      self.modules.darwin.gabbro
      self.modules.darwin.home-manager
      inputs.home-manager.darwinModules.home-manager
      {home-manager.users.derethil = self.modules.homeManager.gabbro-derethil;}
    ];
  };

  # HOME MANAGER DEFINITION

  flake.homeConfigurations."derethil@gabbro" = withSystem "aarch64-darwin" ({pkgs, ...}:
    inputs.home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = {inherit self inputs;};
      modules = [
        self.modules.homeManager.home-manager
        self.modules.homeManager.gabbro-derethil
        self.modules.homeManager.user-derethil
      ];
    });
}
