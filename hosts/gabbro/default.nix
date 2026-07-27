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
      framerate = 60;
      name = "Built-in";
      port = "Built-in";
      primary = true;

      resolution = {
        height = 1964;
        width = 3024;
      };

      wallpaper = "fuji-bird.jpeg";
    }
  ];
in {
  flake = {
    # HOST CONFIGURATION
    modules = {
      darwin.gabbro = {pkgs, ...}: {
        imports = with (mergeModules self.modules.generic self.modules.darwin); [
          bridges
          comms-work
          development
          foundation
          lightweight-gaming
          paneru
          user-derethil
        ];

        internal = {
          inherit flakeRoot;

          dock.apps = [
            {app = "${pkgs.alacritty}/Applications/Alacritty.app";}
            {app = "${pkgs.bruno}/Applications/Bruno.app";}
            {app = "${pkgs.firefox}/Applications/Firefox.app";}
            {app = "${pkgs.internal.stremio}/Applications/Stremio.app";}
            {app = "${pkgs.obsidian}/Applications/Obsidian.app";}
            {app = "${pkgs.prismlauncher}/Applications/PrismLauncher.app";}
            {app = "${pkgs.spotify}/Applications/Spotify.app";}
            {app = "/Applications/Discord.app";}
            {app = "/Applications/Mattermost.app";}
            {app = "/Applications/Steam.app";}
            {app = "/System/Applications/Messages.app";}
          ];
        };

        networking.hostName = "gabbro";
        system.stateVersion = 5;
      };

      # HOME MANAGER CONFIGURATION

      homeManager.gabbro-derethil = {
        imports = with self.modules.homeManager; [
          alacritty
          browsers
          comms-work
          development
          foundation
          lightweight-gaming
          mac-app-util
          media
          paneru
          utilities
        ];

        home.stateVersion = "25.05";

        internal = {
          inherit displays flakeRoot;
        };
      };
    };

    # HOST DEFINITION
    darwinConfigurations.gabbro = inputs.nix-darwin.lib.darwinSystem {
      modules = [
        inputs.home-manager.darwinModules.home-manager
        self.modules.darwin.gabbro
        self.modules.darwin.home-manager
        {home-manager.users.derethil = self.modules.homeManager.gabbro-derethil;}
      ];

      pkgs = withSystem "aarch64-darwin" ({pkgs, ...}: pkgs);
      system = "aarch64-darwin";
    };

    # HOME MANAGER DEFINITION
    homeConfigurations."derethil@gabbro" = withSystem "aarch64-darwin" ({pkgs, ...}:
      inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {inherit inputs self;};

        modules = [
          self.modules.homeManager.gabbro-derethil
          self.modules.homeManager.home-manager
          self.modules.homeManager.user-derethil
        ];
      });
  };
}
